# frozen_string_literal: true

# Responsible for creating parent-child relationships between Works and Collections.
#
# Handles relationships:
# - Work to Collection
# - Work to Work
class CometCreateRelationshipsJob < Bulkrax::CreateRelationshipsJob
  include Hyrax::Lockable

  # @param parent_identifier [String] Work/Collection ID or Bulkrax::Entry source_identifiers
  # @param importer_run [Bulkrax::ImporterRun] current importer run (needed to properly update counters)
  #
  # The entry_identifier is used to lookup the @base_entry for the job (a.k.a. the entry the job was called from).
  # The @base_entry defines the context of the relationship (e.g. "this entry (@base_entry) should have a parent").
  # Whether the @base_entry is the parent or the child in the relationship is determined by the presence of a
  # parent_identifier or child_identifier param. For example, if a parent_identifier is passed, we know @base_entry
  # is the child in the relationship, and vice versa if a child_identifier is passed.
  def perform(parent_identifier:, importer_run_id:)
    importer_run = Bulkrax::ImporterRun.find(importer_run_id)
    ability = Ability.new(importer_run.user)

    parent_entry, parent_record = find_record(parent_identifier, importer_run_id)

    number_of_successes = 0
    number_of_failures = 0
    errors = []

    ActiveRecord::Base.uncached do
      Bulkrax::PendingRelationship.where(parent_id: parent_identifier, importer_run_id: importer_run_id)
        .ordered.find_each do |rel|
        process(relationship: rel, importer_run_id: importer_run_id, parent_record: parent_record, ability: ability)
        number_of_successes += 1
      rescue => e
        number_of_failures += 1
        errors << e
      end
    end

    if errors.present?
      importer_run.increment!(:failed_relationships, number_of_failures)
      parent_entry&.set_status_info(errors.last, importer_run)

      # TODO: This can create an infinite job cycle, consider a time to live tracker.
      reschedule(parent_identifier: parent_identifier, importer_run_id: importer_run_id)
      false # stop current job from continuing to run after rescheduling
    else
      Bulkrax::ImporterRun.find(importer_run_id).increment!(:processed_relationships, number_of_successes)
    end
  end

  # Search entries, collections, and every available work type for a record that
  # has the provided identifier.
  #
  # @param identifier [String] Work/Collection ID or Bulkrax::Entry source_identifier
  # @param importer_run_id [Number] ID of the current_run of this Importer Job
  # @return [Entry, nil], [Work, Collection, nil] Entry if found, otherwise nil and a Work or Collection if found, otherwise nil
  def find_record(identifier, importer_run_id = nil)
    # check for our entry in our current importer first
    importer_id = Bulkrax::ImporterRun.find(importer_run_id).importer_id
    default_scope = {identifier: identifier, importerexporter_type: "Bulkrax::Importer"}

    begin
      # the identifier parameter can be a :source_identifier or the id of an object
      record = Bulkrax::Entry.find_by(default_scope.merge({importerexporter_id: importer_id})) || Bulkrax::Entry.find_by(default_scope)
      record ||= Hyrax.query_service.find_by(id: identifier)
    rescue NameError, Valkyrie::Persistence::ObjectNotFoundError => err
      Hyrax.logger.error(err)
      record = nil
    end

    # return the found entry here instead of searching for it again in the CreateRelationshipsJob
    # also accounts for when the found entry isn't a part of this importer
    record.is_a?(Bulkrax::Entry) ? [record, Hyrax.query_service.find_by_alternate_identifier(alternate_identifier: record.identifier)] : [nil, record]
  end

  private

  def process(relationship:, importer_run_id:, parent_record:, ability:)
    raise "#{relationship} needs a child to create relationship" if relationship.child_id.nil?
    raise "#{relationship} needs a parent to create relationship" if relationship.parent_id.nil?

    _child_entry, child_record = find_record(relationship.child_id, importer_run_id)
    raise "#{relationship} could not find child record" unless child_record

    raise "Cannot add child collection (ID=#{relationship.child_id}) to parent work (ID=#{relationship.parent_id})" if child_record.collection? && parent_record.work?

    ability.authorize!(:edit, child_record)

    # We could do this outside of the loop, but that could lead to odd counter failures.
    ability.authorize!(:edit, parent_record)

    # lock record that need relationship update to avoid concurrent changes
    lock_record_id = parent_record.collection? ? child_record.id.to_s : parent_record.id.to_s
    acquire_lock_for(lock_record_id) do
      parent_record.collection? ? add_to_collection(child_record, parent_record, ability) : add_to_work(child_record, parent_record, ability)

      child_record.file_sets.each(&:update_index) if update_child_records_works_file_sets? && child_record.respond_to?(:file_sets)
      relationship.destroy
    end
  end

  def add_to_collection(child_record, parent_record, ability)
    return child_record if child_record.member_of_collection_ids.any? { |id| id.to_s == parent_record.id.to_s }

    # refresh child record for relationship change
    child_record = Hyrax.query_service.find_by(id: child_record.id.to_s)
    child_record.member_of_collection_ids << parent_record.id

    saved_record = Hyrax.persister.save(resource: child_record)

    Hyrax.publisher.publish("object.metadata.updated", object: saved_record, user: ability.current_user)
    Hyrax.publisher.publish("collection.membership.updated", collection_id: parent_record, user: ability.current_user)

    saved_record
  end

  def add_to_work(child_record, parent_record, ability)
    return true if parent_record.member_ids.any? { |id| id.to_s == child_record.id.to_s }

    # refresh parent record for relationship change
    parent_record = Hyrax.query_service.find_by(id: parent_record.id.to_s)
    parent_record.member_ids << child_record.id

    # TODO: Do we need to save the child record?
    saved_record = Hyrax.persister.save(resource: parent_record)

    Hyrax.publisher.publish("object.metadata.updated", object: saved_record, user: ability.current_user)

    saved_record
  end

  def reschedule(parent_identifier:, importer_run_id:)
    CometCreateRelationshipsJob.set(wait: 10.minutes).perform_later(
      parent_identifier: parent_identifier,
      importer_run_id: importer_run_id
    )
  end
end
