# frozen_string_literal: true

require "surfliner_schema/reader"
require "yaml"

module SurflinerSchema
  ##
  # The schema loader.
  #
  # This is defined as a singleton to allow subclassing and the overriding
  # of search paths.
  class Loader
    include Singleton

    ##
    # Loads one or more YAML schemas, provided as symbols, using the appropriate
    # reader.
    #
    # Schemas are loaded from the `config/metadata` directory; see
    # `spec/fixtures/core_schema.yml` for an example.
    #
    # Use `SurflinerSchema::HyraxLoader` to wrap schemas for use in Hyrax.
    #
    # @param schema [Symbol]
    # @return [SurflinerSchema::Reader::SimpleSchema]
    def load(schema)
      SurflinerSchema::Reader.read(config_for(schema), schema_name: schema)
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
      YAML.safe_load(File.open(schema_config_path))
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
