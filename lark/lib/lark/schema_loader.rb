# frozen_string_literal: true

##
# Utility class to load Surfliner M3 schema
module Lark
  class SchemaLoader < SurflinerSchema::Loader
    def self.default_schemas
      [:m3]
    end

    def self.search_paths
      SurflinerSchema::Loader.search_paths + [Lark.application.settings.root]
    end

    def self.config_location
      "model"
    end
  end
end
