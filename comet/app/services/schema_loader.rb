# frozen_string_literal: true

# This class overrides the standard schema loader to read schema names from the
# configuration.
class SchemaLoader < SurflinerSchema::Loader
  def self.config_location
    Rails.application.config.metadata_config_location
  end

  def self.default_schemas
    Rails.application.config.metadata_config_schemas
  end

  def self.resource_base_class
    ::Resource
  end
end
