# frozen_string_literal: true

require "surfliner_schema/reader/simple_schema"
require "surfliner_schema/reader/error"

module SurflinerSchema
  module Reader
    ##
    # Read a configuration hash using the appropriate reader.
    #
    # @param config [Hash]
    # @param schema_name [Symbol]
    # @return [SurflinerSchema::Reader::SimpleSchema]
    def self.read(config, schema_name:)
      if config.include? "attributes"
        SimpleSchema.new(config["attributes"].transform_keys(&:to_sym))
      else
        # TK: Other schema types (Houndstooth…)
        raise(
          Error::NotRecognized,
          "Schema format not recognized: #{schema_name}"
        )
      end
    end
  end
end
