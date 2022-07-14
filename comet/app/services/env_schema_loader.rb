# frozen_string_literal: true

# this class overrides the standard schema loader to read schema names from the
# environment
class EnvSchemaLoader < SurflinerSchema::Loader
  def self.config_location
    Rails.application.config.metadata_config_location
  end

  def self.default_schemas
    Rails.application.config.metadata_config_schemas
  end
end
