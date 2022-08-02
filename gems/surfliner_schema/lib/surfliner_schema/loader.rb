# frozen_string_literal: true

require "yaml"

module SurflinerSchema
  ##
  # The schema loader.
  class Loader
    ##
    # Initialize a new loader for the provided schema names.
    #
    # Schemas are loaded from the +config/metadata+ directory by default.
    # Override the +schema_location+ class method to adjust this.
    #
    # If no argument is provided, the +default_schemas+ class method will be
    # used as default; the anticipated common use·case is that a given
    # application will be using a predefined set of schemas (e·g specified in
    # an environment variable).
    #
    # @param schema_names [Array<Symbol>]
    def initialize(schema_names = nil)
      @readers = (schema_names || self.class.default_schemas).map do |schema|
        SurflinerSchema::Reader.read(config_for(schema), schema_name: schema)
      end
    end

    ##
    # A hash mapping attributes with the provided availability to their form
    # options.
    #
    # This method is provided for compatibility with Hyrax’s FormFields module
    # builder. The +schema+ parameter does not specify the schema file, but the
    # availability.
    #
    # @param availability [Symbol]
    # @return [Hash{Symbol => Dry::Types::Type}]
    def form_definitions_for(schema:)
      {}.merge(*@readers.map { |reader|
        reader.form_options(availability: schema)
      })
    end

    ##
    # A hash mapping indicies with the provided availability to their
    # corresponding names.
    #
    # This method is provided for compatibility with Hyrax’s Indexer module
    # builder. The +schema+ parameter does not specify the schema file, but the
    # availability.
    #
    # @param schema [Symbol]
    # @return [{Symbol => Symbol}]
    def index_rules_for(schema:)
      {}.merge(*@readers.map { |reader|
        reader.indices(availability: schema).transform_values { |dfn|
          dfn[:name]
        }
      })
    end

    ##
    # A hash mapping property names with the provided availability to their
    # definitions.
    #
    # @param availability [Symbol]
    # @return [{Symbol => SurflinerSchema::Property}]
    def properties_for(availability)
      {}.merge(*@readers.map { |reader|
        reader.properties(availability: availability)
      })
    end

    ##
    # A hash mapping property names with the provided availability to a set of
    # mappings for the provided schema.
    #
    # @param availability [Symbol]
    # @param schema_iri [String]
    # @return [{Symbol => Set<String>}]
    def property_mappings_for(availability, schema_iri:)
      {}.merge(*@readers.map { |reader|
        reader.properties(availability: availability).transform_values { |property|
          property.mappings_for(schema_iri)
        }
      })
    end

    ##
    # A hash mapping property names with the provided availability to their
    # types.
    #
    # @param availability [Symbol]
    # @return [Hash{Symbol => Dry::Types::Type}]
    def struct_attributes_for(availability)
      {}.merge(*@readers.map { |reader|
        reader.to_struct_attributes(availability: availability)
      })
    end

    private

    ##
    # The configuration for the requested schema.
    #
    # @param schema {Symbol}
    # @return {Object}
    def config_for(schema)
      paths_for_schema = self.class.search_paths.flat_map do |root|
        [
          File.join(root, self.class.config_location, "#{schema}.yaml"),
          File.join(root, self.class.config_location, "#{schema}.yml")
        ]
      end
      schema_config_path = paths_for_schema.find { |path| File.exist? path }
      unless schema_config_path
        raise(
          Reader::Error::UndefinedSchema,
          "No configuration file found for schema: #{schema}"
        )
      end
      YAML.safe_load(File.open(schema_config_path), aliases: true)
    end

    public

    ##
    # The location at which metadata schemas can be found.
    #
    # @return [String]
    def self.config_location
      "config/metadata"
    end

    ##
    # The default schema names to load.
    #
    # @return [Array<Symbol>]
    def self.default_schemas
      []
    end

    ##
    # The root paths from which to search for schemas.
    #
    # @return [Array<String>]
    def self.search_paths
      paths = []
      paths << Rails.root if const_defined?(:Rails) && Rails.respond_to?(:root)
      paths << Hyrax::Engine.root if const_defined?(:Hyrax) && Hyrax.const_defined?(:Engine) && Hyrax::Engine.respond_to?(:root)
      paths << Pathname.new(Dir.pwd) if paths.empty?
      paths
    end
  end
end
