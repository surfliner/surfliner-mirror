# frozen_string_literal: true

if Rails.application.config.feature_bulkrax
  Hyrax::DashboardController.sidebar_partials[:repository_content] <<
    "hyrax/dashboard/sidebar/bulkrax_sidebar_additions"
end

Bulkrax.setup do |config|
  config.object_factory = Bulkrax::ValkyrieObjectFactory
  config.default_work_type = "GenericObject"
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

module CsvParserExt
  ##
  # Note: use 'perform_now' to facilitate development for now
  # @return [String]
  def perform_method
    "perform_now"
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
    build_relationship_metadata

    # Extract M3 properties before other configured mappings.
    build_m3_metadata

    build_mapping_metadata

    self.save!

    self.parsed_metadata
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
end
# rubocop:enable Style/RedundantSelf

[Bulkrax::CsvEntry, Bulkrax::CsvEntry.singleton_class].each do |mod|
  mod.prepend EntryExt
end
