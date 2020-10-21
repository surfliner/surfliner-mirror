# frozen_string_literal: true

##
# @see https://dry-rb.org/gems/dry-validation/
class AuthorityContract < Dry::Validation::Contract
  config.validate_keys = true

  schema { optional(:scheme) }

  def self.[](schema_name_or_config)
    schema_config =
      case schema_name_or_config
      when Symbol
        YAML.load_file(File.expand_path("../../model/#{schema_name_or_config}.yml", __dir__))
      else
        schema_name_or_config
      end

    Class.new(self) do
      schema do
        schema_config.each do |definition|
          term = definition.keys.first
          cardinality = definition[term].fetch('cardinality', '0..*').to_s

          if cardinality == '1'
            required(term.underscore.to_sym)
          else
            optional(term.underscore.to_sym)
          end
        end
      end
    end
  end
end
