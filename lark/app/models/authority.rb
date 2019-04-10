# frozen_string_literal: true

##
# @abstract An abstract Authority record built from/saved to the index.
class Authority < Valkyrie::Resource
  class << self
    def define_schema(config)
      config.each do |de|
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

  ##
  # @return [String] constant
  def scheme
    self.class::SCHEMA
  end
end
