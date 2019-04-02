# frozen_string_literal: true

##
# Define attributes for models in lark
module Schema
  ##
  # Dynamically generate the attributes basing on the structure data in model
  # definition lark/model/concept.yaml for the concept model
  module Concept
    extend ActiveSupport::Concern

    included do
      model_file = File.expand_path('../../../model/concept.yml', __dir__)
      definitions = YAML.load_file(model_file)

      definitions.each do |de|
        term = de.keys.first

        case de[term]['range']['uri']
        when 'xsd:anyURI'
          attribute term.underscore.to_sym,
                    Valkyrie::Types::Set.of(Valkyrie::Types::URI)
        else
          attribute term.underscore.to_sym, Valkyrie::Types::Set
        end
      end
    end
  end
end
