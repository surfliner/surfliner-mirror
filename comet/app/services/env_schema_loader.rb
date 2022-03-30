# frozen_string_literal: true

# this class overrides the standard schema loader to read schema names from the
# environment, instead of taking an argument
class EnvSchemaLoader < SurflinerSchema::Loader
  def attributes_for(schema)
    {}.merge(*ENV["METADATA_MODELS"].to_s.split(",").map { |f| super(f) })
  end
end
