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

    def self.valkyrie_resource_class_for(_schema_name)
      ->(resource_class) do
        (resource_class.name == :label) ? Lark::BaseLabel : Valkyrie::Resource
      end
    end
  end
end
