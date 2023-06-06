# frozen_string_literal: true

module Contracts
  ##
  # @see https://dry-rb.org/gems/dry-validation/
  class AuthorityContract < Dry::Validation::Contract
    config.validate_keys = true

    schema do
      optional(:id)
    end

    def self.[](availability)
      Class.new(self) do
        schema do
          Lark::SchemaLoader.new.form_definitions_for(availability).values.each do |property|
            property.required? ? required(property.name) : optional(property.name)
          end
        end
      end
    end
  end
end
