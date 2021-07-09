# frozen_string_literal: true

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
