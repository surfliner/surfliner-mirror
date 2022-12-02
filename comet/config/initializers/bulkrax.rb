# frozen_string_literal: true

if Rails.application.config.feature_bulkrax
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
  end

  [Bulkrax::CsvParser, Bulkrax::CsvParser.singleton_class].each do |mod|
    mod.prepend CsvParserExt
  end

  Hyrax::DashboardController.sidebar_partials[:repository_content] <<
    "hyrax/dashboard/sidebar/bulkrax_sidebar_additions"
end
