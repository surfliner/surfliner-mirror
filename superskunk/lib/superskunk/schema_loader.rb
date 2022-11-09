# frozen_string_literal: true

##
# Utility class to load Surfliner M3 schema
module Superskunk
  class SchemaLoader < SurflinerSchema::Loader
    def self.default_schemas
      ENV["METADATA_MODELS"].to_s.split(",").map(&:to_sym)
    end

    def self.search_paths
      SurflinerSchema::Loader.search_paths + [
        File.join(Rails.root, "..")
      ]
    end

    def self.resource_base_class
      ::Superskunk::Resource
    end
  end
end
