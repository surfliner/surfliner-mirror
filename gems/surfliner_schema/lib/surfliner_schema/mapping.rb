# frozen_string_literal: true

require "valkyrie"

module SurflinerSchema
  ##
  # A sectioning division of properties within a resource.
  class Mapping < Dry::Struct
    ##
    # The internal name used for the mapping.
    attribute :name, Valkyrie::Types::Coercible::Symbol

    ##
    # The human‐readable display label for the mapping.
    attribute :display_label, Valkyrie::Types::Coercible::String

    ##
    # The IRI which identifies the mapping.
    attribute :iri, Valkyrie::Types::Coercible::String

    ##
    # Returns the IRI of the mapping.
    #
    # @return [String]
    def to_s
      iri
    end
  end
end
