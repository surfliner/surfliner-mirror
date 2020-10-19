# frozen_string_literal: true

##
# @abstract An abstract Authority record built from/saved to the index.
class Authority < Valkyrie::Resource
  SCHEMA = 'http://www.w3.org/2004/02/skos/core#ConceptScheme'

  class << self
    def define_schema(config)
      config.each do |definition|
        term = definition.keys.first

        attribute term.underscore.to_sym,
                  type_for(range: definition[term]['range']['uri'])
      end

      attribute :scheme, Valkyrie::Types::Strict::String.default(self::SCHEMA)
    end

    private

    def type_for(range:)
      case range
      when 'xsd:anyURI'
        Valkyrie::Types::Set.of(Valkyrie::Types::URI)
      else
        Valkyrie::Types::Set
      end
    end
  end
end
