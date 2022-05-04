# frozen_string_literal: true

# this class overrides the standard schema loader to read schema names from the
# environment
class EnvSchemaLoader < SurflinerSchema::Loader
  def self.default_schemas
    ENV["METADATA_MODELS"].to_s.split(",").map(&:to_sym)
  end
end
