# frozen_string_literal: true

require "surfliner_schema/undefined_schema_error"
require "valkyrie"

module SurflinerSchema
  ##
  # A reader for one or more YAML schemas, provided as symbols upon initialization.
  #
  # Schemas are loaded from the `config/metadata` directory; see `spec/fixtures/core_schema.yml` for an example.
  #
  # Use `SurflinerSchema::HyraxLoader` instead as a loader for schemas within Hyrax.
  #
  # @param [Array<Symbol>]
  class Reader
    ##
    # Creates a new Reader for the provided schemas.
    #
    # @param [Array<Symbol>] *schemas
    def initialize(*schemas)
      @schemas = schemas
      @attributes_config = schema_config["attributes"].transform_keys(&:to_sym)
    end

    ##
    # A hash mapping attributes to their definitions.
    #
    # @return {Symbol => Object}
    def attributes
      @attributes_config.each_with_object({}) do |(name, config), dfns|
        dfn = {
          name: name,
          type: self.class.valkyrie_type_for(config["type"]),
          form_options: config.fetch("form", {}).transform_keys(&:to_sym),
          index_keys: config.fetch("index_keys", []).map(&:to_sym)
        }
        dfn[:type] = Valkyrie::Types::Array.of(dfn[:type]) if config["multiple"]
        dfns[name] = dfn
      end
    end

    ##
    # A hash mapping attributes to their form options.
    #
    # @return {Symbol => {Symbol => Object}}
    def form_options
      attributes
        .transform_values { |dfn| dfn[:form_options] }
        .filter { |_, opts| opts && !opts.empty? }
    end

    ##
    # A hash mapping indices to attribute definitions.
    #
    # @return {Symbol => Object}
    def indices
      attributes.each_with_object({}) do |(_name, dfn), hash|
        dfn[:index_keys].each { |key| hash[key] = dfn }
      end
    end

    ##
    # A hash mapping attributes to Valkyrie types.
    #
    # @return {Symbol => Dry::Types::Type}
    def types
      attributes.transform_values { |dfn| dfn[:type] }
    end

    private

    ##
    # A hash combining the configurations of all the requested schemas.
    #
    # @return {Object}
    def schema_config
      {}.merge(*configs)
    end

    ##
    # An array of the configurations of all the requested schemas.
    #
    # @return {Array<Object>}
    def configs
      @schemas.map do |schema|
        paths_for_schema = self.class.search_paths.flat_map do |root|
          [
            File.join(root, self.class.config_location, "#{schema}.yaml"),
            File.join(root, self.class.config_location, "#{schema}.yml")
          ]
        end
        schema_config_path = paths_for_schema.find { |path| File.exist? path }
        raise(UndefinedSchemaError, "No schema defined: #{schema}") unless schema_config_path
        YAML.safe_load(File.open(schema_config_path))
      end
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

    ##
    # The Valkyrie type which corresponds to the provided type string.
    #
    # @param [String] type_str
    #
    # @return [Dry::Types::Type]
    def self.valkyrie_type_for(type_str)
      case type_str
      when "id"
        Valkyrie::Types::ID
      when "uri"
        Valkyrie::Types::URI
      when "date_time"
        Valkyrie::Types::DateTime
      else
        "Valkyrie::Types::#{type_str.capitalize}".constantize
      end
    end
  end
end
