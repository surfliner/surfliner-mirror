# frozen_string_literal: true

module Bulkrax
  class ValkyrieObjectFactory < ObjectFactory
    ##
    # Retrieve properties from M3 model
    # @param klass the model
    # return Array<string>
    def self.schema_properties(klass)
      @schema_properties_map ||= {}

      klass_key = klass.name
      unless @schema_properties_map.has_key?(klass_key)
        @schema_properties_map[klass_key] = ::SchemaLoader.new.properties_for(klass.name.underscore.to_sym).values.map { |pro| pro.name.to_s }
      end

      @schema_properties_map[klass_key]
    end

    def run!
      run
      return object if object.persisted?

      raise(RecordInvalid, object)
    end

    def find_by_id
      Hyrax.query_service.find_by(id: attributes[:id]) if attributes.key? :id
    end

    def search_by_identifier
      # Query can return partial matches (something6 matches both something6 and something68)
      # so we need to weed out any that are not the correct full match. But other items might be
      # in the multivalued field, so we have to go through them one at a time.
      match = Hyrax.query_service.find_by_alternate_identifier(alternate_identifier: source_identifier_value)

      return match if match
    rescue => err
      Hyrax.logger.error(err)
      false
    end

    # An ActiveFedora bug when there are many habtm <-> has_many associations means they won't all get saved.
    # https://github.com/projecthydra/active_fedora/issues/874
    # 2+ years later, still open!
    def create
      attrs = transform_attributes
        .merge(alternate_ids: [source_identifier_value])
        .symbolize_keys

      cx = Hyrax::Forms::ResourceForm.for(klass.new).prepopulate!
      cx.validate(attrs)

      result = transaction
        .with_step_args(
          # "work_resource.add_to_parent" => {parent_id: @related_parents_parsed_mapping, user: @user},
          "add_bulkrax_files" => {files: get_s3_files(remote_files: attributes["remote_files"]), user: @user},
          "change_set.set_user_as_depositor" => {user: @user},
          "work_resource.change_depositor" => {user: @user}
          # TODO: uncomment when we upgrade Hyrax 4.x
          # 'work_resource.save_acl' => { permissions_params: [attrs.try('visibility') || 'open'].compact }
        )
        .call(cx)

      @object = result.value!
    end

    def update
      raise "Object doesn't exist" unless @object
      destroy_existing_files if @replace_files && ![Collection, FileSet].include?(klass)
      attrs = transform_attributes(update: true)
      run_callbacks :save do
        if klass == Collection
          update_collection(attrs)
        elsif klass == FileSet
          update_file_set(attrs)
        else
          @object = persist_metadata(resource: @object, attrs: attrs)
        end
      end
      @object = apply_depositor_metadata(@object, @user) if @object.depositor.nil?
      log_updated(@object)
    end

    def persist_metadata(resource:, attrs:)
      attrs.each { |k, v| resource.public_send("#{k}=", v) if resource.respond_to?(k.to_s) }
      object = Hyrax.persister.save(resource: resource)
      # Index the object
      Hyrax.publisher.publish("object.metadata.updated", object: object, user: @user)
      object
    end

    def get_s3_files(remote_files: {})
      if remote_files.blank?
        Hyrax.logger.info "No remote files listed for #{attributes["source_identifier"]}"
        return []
      end

      s3_bucket_name = ENV.fetch("STAGING_AREA_S3_BUCKET", "comet-staging-area-#{Rails.env}")
      s3_bucket = Rails.application.config.staging_area_s3_connection
        .directories.get(s3_bucket_name)

      remote_files.map { |r| r["url"] }.map do |key|
        s3_bucket.files.get(key)
      end.compact
    end

    ##
    # TODO: What else fields are necessary: %i[id edit_users edit_groups read_groups work_members_attributes]?
    # Regardless of what the Parser gives us, these are the properties we are prepared to accept.
    def permitted_attributes
      Bulkrax::ValkyrieObjectFactory.schema_properties(klass) +
        %i[
          admin_set_id
          title
          visibility
        ]
    end

    def apply_depositor_metadata(object, user)
      object.depositor = user.email
      object = Hyrax.persister.save(resource: object)
      Hyrax.publisher.publish("object.metadata.updated", object: object, user: @user)
      object
    end

    private

    def transaction
      steps = Hyrax::Transactions::WorkCreate::DEFAULT_STEPS.dup
      steps[steps.index("work_resource.add_file_sets")] = "add_bulkrax_files"

      Hyrax::Transactions::WorkCreate.new(steps: steps)
    end
  end

  class RecordInvalid < StandardError
  end
end
