# frozen_string_literal: true

module SurflinerSchema
  ##
  # A single, schema‐defined value for use in a property’s “controlled values”.
  class ControlledValue < Dry::Struct
    ##
    # The internal name used for the controlled value.
    attribute :name, Valkyrie::Types::Coercible::Symbol

    ##
    # The human‐readable display label for the controlled value.
    attribute :display_label, Valkyrie::Types::Coercible::String

    ##
    # The IRI corresponding to the controlled value.
    attribute :iri, Valkyrie::Types.Constructor(RDF::URI)
  end
end
