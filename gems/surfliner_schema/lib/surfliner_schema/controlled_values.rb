# frozen_string_literal: true

module SurflinerSchema
  ##
  # A struct defining the controlled values of a property.
  #
  # Sources point to external definitions, while values provide internal
  # definitions. The resulting list of controlled values should be the union of
  # these.
  class ControlledValues < Dry::Struct
    ##
    # IRIs of external sources for controlled values.
    attribute :sources, Valkyrie::Types::Set.of(
      Valkyrie::Types.Constructor(RDF::URI)
    ).default { [] }

    ##
    # A map of local controlled value names to their definitions.
    attribute :values, Valkyrie::Types::Hash.map(
      Valkyrie::Types::Symbol,
      SurflinerSchema::ControlledValue
    ).default { {} }
  end
end
