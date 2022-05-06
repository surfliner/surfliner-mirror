# frozen_string_literal: true

require "surfliner_schema/reader/error"
require "surfliner_schema/reader/houndstooth"
require "surfliner_schema/reader/simple_schema"

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
      elsif config.fetch("m3_version", "").start_with?("1.0")
        Houndstooth.new(config)
      else
        raise(
          Error::NotRecognized,
          "Schema format not recognized: #{schema_name}"
        )
      end
    end
  end
end
