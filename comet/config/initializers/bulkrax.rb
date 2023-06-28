# frozen_string_literal: true

if Rails.application.config.feature_bulkrax
  Hyrax::DashboardController.sidebar_partials[:repository_content] <<
    "hyrax/dashboard/sidebar/bulkrax_sidebar_additions"
end

Bulkrax.setup do |config|
  config.object_factory = Bulkrax::ValkyrieObjectFactory
  config.default_work_type = "GenericObject"
  config.relationship_job_class = "CometCreateRelationshipsJob"
  config.fill_in_blank_source_identifiers = ->(parser, index) { "b-#{parser.importer.id}-#{index}" }

  # Specify the delimiter regular expression for splitting an attribute's values into a multi-value array.
  config.multi_value_element_split_on = /\s*\|\s*/
  # Specify the delimiter for joining an attribute's multi-value array into a string.
  config.multi_value_element_join_on = " | "
end

Bulkrax.export_path = ENV.fetch("BULKRAX_EXPORT_PATH", "tmp/exports")

Bulkrax.parsers = [
  # {name: "OAI - Dublin Core", class_name: "Bulkrax::OaiDcParser", partial: "oai_fields"},
  # {name: "OAI - Qualified Dublin Core", class_name: "Bulkrax::OaiQualifiedDcParser", partial: "oai_fields"},
  {name: "CSV - Comma Separated Values", class_name: "Bulkrax::CometCsvParser", partial: "csv_fields_no_visibility"}
  # {name: "Bagit", class_name: "Bulkrax::BagitParser", partial: "bagit_fields"},
  # {name: "XML", class_name: "Bulkrax::XmlParser", partial: "xml_fields"}
]

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

  # @Override support pcdm use attributes
  def supported_bulkrax_fields
    @supported_bulkrax_fields ||=
      %W[
        id
        file
        remote_files
        model
        visibility
        delete
        use:PreservationFile
        use:ServiceFile
        #{related_parents_parsed_mapping}
        #{related_children_parsed_mapping}
      ]
  end

  ##
  # Determine a multiple properties field
  def multiple?(field)
    @multiple_bulkrax_fields ||=
      %W[
        file
        remote_files
        use:PreservationFile
        use:ServiceFile
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
    form_definition = schema_form_definitions[field.to_sym]
    form_definition.nil? ? false : form_definition.multiple?
  end

  # override: we want to directly infer from a property being multiple that we should split when it's a String
  def multiple_metadata(content)
    return unless content

    case content
    when Nokogiri::XML::NodeSet
      content&.content
    when Array
      content
    when Hash
      Array.wrap(content)
    when String
      String(content).strip.split(Bulkrax.multi_value_element_split_on)
    else
      Array.wrap(content)
    end
  end

  def schema_form_definitions
    @schema_form_definitions ||= ::SchemaLoader.new.form_definitions_for(factory_class.name.underscore.to_sym)
  end
end

[Bulkrax::HasMatchers, Bulkrax::HasMatchers.singleton_class].each do |mod|
  mod.prepend HasMappingExt
end
