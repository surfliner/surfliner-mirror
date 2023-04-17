# frozen_string_literal: true

if Rails.application.config.feature_bulkrax
  Hyrax::DashboardController.sidebar_partials[:repository_content] <<
    "hyrax/dashboard/sidebar/bulkrax_sidebar_additions"
end

Bulkrax.setup do |config|
  config.object_factory = Bulkrax::ValkyrieObjectFactory
  config.default_work_type = "GenericObject"
end

Bulkrax.parsers = [
  {name: "OAI - Dublin Core", class_name: "Bulkrax::OaiDcParser", partial: "oai_fields"},
  {name: "OAI - Qualified Dublin Core", class_name: "Bulkrax::OaiQualifiedDcParser", partial: "oai_fields"},
  {name: "CSV - Comma Separated Values", class_name: "Bulkrax::CsvParser", partial: "csv_fields_no_visibility"},
  {name: "Bagit", class_name: "Bulkrax::BagitParser", partial: "bagit_fields"},
  {name: "XML", class_name: "Bulkrax::XmlParser", partial: "xml_fields"}
]

module Bulkrax
  # @override return the valkyrie ::FileSet in comet
  def file_model_class
    ::FileSet
  end
end

module HasMappingExt
  ##
  # Field of the model that can be supported
  def field_supported?(field)
    field = field.gsub("_attributes", "")

    return false if excluded?(field)
    return true if supported_bulkrax_fields.include?(field)
    # title is not defined in M3
    return true if field == "title"

    property_defined = factory_class.singleton_methods.include?(:properties) && factory_class.properties[field].present?

    factory_class.method_defined?(field) && (Bulkrax::ValkyrieObjectFactory.schema_properties(factory_class).include?(field) || property_defined)
  end

  ##
  # Determine a multiple properties field
  def multiple?(field)
    @multiple_bulkrax_fields ||=
      %W[
        file
        remote_files
        rights_statement
        #{related_parents_parsed_mapping}
        #{related_children_parsed_mapping}
      ]

    return true if @multiple_bulkrax_fields.include?(field)
    return false if field == "model"
    # title is not defined in M3
    return false if field == "title"

    field_supported?(field) && (multiple_field?(field) || factory_class.singleton_methods.include?(:properties) && factory_class&.properties&.[](field)&.[]("multiple"))
  end

  def multiple_field?(field)
    form_definition = schema_form_definitions[field]
    form_definition.nil? ? false : form_definition.multiple?
  end

  def schema_form_definitions
    @schema_form_definitions ||= ::SchemaLoader.new.form_definitions_for(factory_class.name.underscore.to_sym)
  end
end

[Bulkrax::HasMatchers, Bulkrax::HasMatchers.singleton_class].each do |mod|
  mod.prepend HasMappingExt
end

module CsvEntryExt
  def self.parent_field(parser)
    parser.related_parents_parsed_mapping
  end
end

[Bulkrax::CsvEntry, Bulkrax::CsvEntry.singleton_class].each do |mod|
  mod.prepend CsvEntryExt
end

module ParserExportRecordSetBaseExt
  # @override count works only in comet
  # @return [Integer]
  def count
    sum = works.count
    return sum if limit.zero?
    return limit if sum > limit
    sum
  end

  # @override Yield works only for comet.  Once we've yielded as many times
  # as the parser's limit, we break the iteration and return.
  #
  # @yieldparam id [String] The ID of the work/collection/file_set
  # @yieldparam entry_class [Class] The parser associated entry class for the
  #             work/collection/file_set.
  #
  # @note The order of what we yield has been previously determined.
  def each
    counter = 0

    works.each do |work|
      break if limit_reached?(limit, counter)
      yield(work.fetch("id"), work_entry_class)
      counter += 1
    end
  end
end

[Bulkrax::ParserExportRecordSet::Base, Bulkrax::ParserExportRecordSet::Base.singleton_class].each do |mod|
  mod.prepend ParserExportRecordSetBaseExt
end

module ApplicationParserExt
  # @override exclude source idetifier from required_elements list
  # @return [Array<String>]
  def required_elements
    super - [source_identifier]
  end

  # @override to allow source idetifier to be accepted
  # @return [TrueClass,FalseClass]
  def record_has_source_identifier(record, index)
    if record[source_identifier].blank?
      if Bulkrax.fill_in_blank_source_identifiers.present?
        record[source_identifier] = Bulkrax.fill_in_blank_source_identifiers.call(self, index)
      else
        false
      end
    else
      true
    end
  end
end

[Bulkrax::ApplicationParser, Bulkrax::ApplicationParser.singleton_class].each do |mod|
  mod.prepend ApplicationParserExt
end

module CsvParserExt
  ##
  # Note: use 'perform_now' to facilitate development for now
  # @return [String]
  def perform_method
    "perform_now"
  end

  # @override create objects for records without source identitier anyway
  def create_objects(types_array = nil)
    index = 0
    (types_array || %w[collection work file_set relationship]).each do |type|
      if type.eql?("relationship")
        Bulkrax::ScheduleRelationshipsJob.set(wait: 5.minutes).perform_later(importer_id: importerexporter.id)
        next
      end
      send(type.pluralize).each do |current_record|
        break if limit_reached?(limit, index)

        seen[current_record[source_identifier]] = true if record_has_source_identifier(current_record, index)

        create_entry_and_job(current_record, type)
        increment_counters(index, "#{type}": true)
        index += 1
      end
      importer.record_status
    end
    true
  rescue => e
    set_status_info(e)
  end

  # Set the following instance variables: @work_ids, @collection_ids, @file_set_ids
  # @see #current_record_ids
  def set_ids_for_exporting_from_importer
    entry_ids = Bulkrax::Importer.find(importerexporter.export_source).entries.pluck(:id)
    complete_statuses = Bulkrax::Status.latest_by_statusable
      .includes(:statusable)
      .where("bulkrax_statuses.statusable_id IN (?) AND bulkrax_statuses.statusable_type = ? AND status_message = ?", entry_ids, "Bulkrax::Entry", "Complete")
    complete_entry_identifiers = complete_statuses.map { |s| s.statusable&.identifier&.gsub(":", ":") }

    all_results = Hyrax.custom_queries.find_many_by_alternate_ids(alternate_ids: complete_entry_identifiers)
    {:@work_ids => ::Hyrax.config.curation_concerns, :@collection_ids => [::Collection], :@file_set_ids => [::FileSet]}.each do |instance_var, models_to_search|
      instance_variable_set(instance_var, all_results.select { |w| models_to_search.any? { |m| w.is_a? m } }.map { |w| w.id.to_s })
    end
  end

  ##
  # Override to reomve the have exclamation mark from`Array.uniq` to avoid error "undefined method `delete" for nil:NilClass"
  def object_names
    return @object_names if @object_names

    @object_names = mapping.values.map { |value| value["object"] }
    @object_names.uniq.delete(nil)

    @object_names
  end

  # find the related file set ids so entries can be made for export
  def find_child_file_sets(work_ids)
    work_ids.each do |id|
      work = Hyrax.query_service.find_by(id: id)
      Hyrax.custom_queries.find_child_file_set_ids(resource: work).each { |fs_id| @file_set_ids << fs_id.to_s }
    end
  end

  def store_files(identifier, folder_count)
    record = Hyrax.query_service.find_by(id: identifier)
    return unless record

    file_sets = record.file_set? ? Array.wrap(record) : Hyrax.custom_queries.find_child_file_sets(resource: record)
    file_sets << record.thumbnail if exporter.include_thumbnails && record.thumbnail.present? && record.work?
    file_sets.each do |fs|
      path = File.join(exporter_export_path, folder_count, "files")
      FileUtils.mkdir_p(path) unless File.exist? path
      # file = filename(fs)
      # next if file.blank? || fs.original_file.blank?
      file_metadata = Hyrax::FileSetFileService.new(file_set: fs).original_file
      file = Hyrax.storage_adapter.find_by(id: file_metadata.file_identifier)

      file.rewind
      File.open(File.join(path, file_metadata.original_filename), "wb") do |f|
        f.write(file.read)
        f.close
      end
    end
  end
end

[Bulkrax::CsvParser, Bulkrax::CsvParser.singleton_class].each do |mod|
  mod.prepend CsvParserExt
end

module EntryExt
  # rubocop:disable Style/RedundantSelf
  def hyrax_record
    @hyrax_record ||= Hyrax.query_service.find_by(id: self.identifier)
  end
  # rubocop:enable Style/RedundantSelf
end

[Bulkrax::Entry, Bulkrax::Entry.singleton_class].each do |mod|
  mod.prepend EntryExt
end

# rubocop:disable Style/RedundantSelf
module CsvEntryExt
  # Metadata required by Bulkrax for round-tripping
  def build_system_metadata
    self.parsed_metadata["id"] = hyrax_record.id.to_s
    self.parsed_metadata[source_identifier] = hyrax_record.alternate_ids.first.to_s
    self.parsed_metadata[key_for_export("model")] = hyrax_record.class.name
  end

  ##
  # Override to add M3 properties
  def build_export_metadata
    self.parsed_metadata = {}

    build_system_metadata
    build_files_metadata unless hyrax_record.is_a?(Collection)

    # A hack to initiate mapping for related_parents_parsed_mapping to avoid error.
    # see Bulkrax::CsvEntry#build_relationship_metadata
    mapping[related_parents_parsed_mapping] = mapping[related_parents_parsed_mapping] || {}
    build_relationship_metadata

    # Extract M3 properties before other configured mappings.
    build_m3_metadata

    build_mapping_metadata

    self.save!

    self.parsed_metadata
  end

  def build_files_metadata
    # Note: Bulkrax attaching files to the FileSet row only so we don't have duplicates when importing to a new tenant
    # Comet will attach file wth filename as column to objects metadata
    file_mapping = key_for_export("file")
    file_sets = hyrax_record.file_set? ? Array.wrap(hyrax_record) : Hyrax.custom_queries.find_child_file_sets(resource: hyrax_record)
    filenames = map_file_sets(file_sets)
    handle_join_on_export(file_mapping, filenames, mapping["file"]&.[]("join")&.present?)
  end

  ##
  # Override to remove the properties that have custom mappings from parsed_metadata, which are extracted from M3 mappings.
  def build_value(key, value)
    data = hyrax_record.send(key.to_s)
    if data.is_a?(ActiveTriples::Relation)
      if value["join"]
        parsed_metadata[key_for_export(key)] = data.map { |d| prepare_export_data(d) }.join(Bulkrax.multi_value_element_join_on).to_s
      else
        data.each_with_index do |d, i|
          parsed_metadata["#{key_for_export(key)}_#{i + 1}"] = prepare_export_data(d)
        end
      end
    else
      # Now delete the mapping from m3 since custom mapping is defined for the property
      parsed_metadata.delete(key) if parsed_metadata.key? key

      parsed_metadata[key_for_export(key)] = prepare_export_data(data)
    end
  end

  ##
  # Add mappings from M3
  # TODO: How values for multi-value field are delimited?
  def build_m3_metadata
    Bulkrax::ValkyrieObjectFactory.schema_properties(hyrax_record.class).each do |pro|
      value = hyrax_record.send(pro)
      self.parsed_metadata[pro] = value.present? ? value.join("|") : nil
    end

    self.parsed_metadata["title"] = hyrax_record.send(:title).first
  end

  private

  def map_file_sets(file_sets)
    file_sets.map { |fs| Hyrax::FileSetFileService.new(file_set: fs)&.original_file&.original_filename }.compact
  end
end
# rubocop:enable Style/RedundantSelf

[Bulkrax::CsvEntry, Bulkrax::CsvEntry.singleton_class].each do |mod|
  mod.prepend EntryExt
end

require Rails.root.join("lib/hyrax/transactions/steps/add_bulkrax_files")

Hyrax::Transactions::Container.register "add_bulkrax_files" do
  Hyrax::Transactions::Steps::AddBulkraxFiles.new
end
