# frozen_string_literal: true

# this class overrides the standard schema loader to read schema names from the
# environment, instead of taking an argument
class EnvSchemaLoader < Hyrax::SimpleSchemaLoader
  def metadata_models
    @metadata_models ||= ENV["METADATA_MODELS"]
      .to_s
      .split(",")
      .map(&:to_sym)
  end

  def definitions(_schema_name)
    metadata_models.map do |model|
      schema_config(model)["attributes"].map do |name, config|
        AttributeDefinition.new(name, config)
      end
    end.flatten
  end
end
