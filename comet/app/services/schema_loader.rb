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

  ##
  # Provide a transformation function to coerce controlled values to their URI’s
  # within the schema & form.
  def self.property_transform_for(_schema_name)
    ->(value, property:, availability:) {
      begin
        # This will raise a +Qa::InvalidSubAuthority+ error if the property is not
        # a controlled value.
        authority = Qa::Authorities::Schema.property_authority_for(name: property.name, availability: availability)
        query_result = authority.find(value) # returns empty hash on failure
        raise ArgumentError unless query_result.include?(:uri)
        query_result[:uri]
      rescue Qa::InvalidSubAuthority
        # Just return the value unmodified.
        value
      end
    }
  end

  def self.valkyrie_resource_class_for(_schema_name)
    ::Resource
  end
end
