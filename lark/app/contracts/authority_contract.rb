# frozen_string_literal: true

##
# @see https://dry-rb.org/gems/dry-validation/
class AuthorityContract < Dry::Validation::Contract
  config.validate_keys = true

  schema { optional(:scheme) }

  def self.[](schema_name)
    Class.new(self) do
      schema do
        Lark::Schema(schema_name).each_property do |property|
          property.required? ? required(property.name) : optional(property.name)
        end
      end
    end
  end
end
