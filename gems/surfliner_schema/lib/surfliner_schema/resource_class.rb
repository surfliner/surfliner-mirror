# frozen_string_literal: true

module SurflinerSchema
  ##
  # A conceptual “class” of resource, as defined by M3.
  class ResourceClass < Dry::Struct
    ##
    # The internal name used for the class.
    attribute :name, Valkyrie::Types::Coercible::Symbol

    ##
    # The human‐readable display label for the class.
    attribute :display_label, Valkyrie::Types::Coercible::String

    ##
    # The IRI which identifies the class.
    attribute :iri, Valkyrie::Types::Coercible::String.optional.default(nil)

    ##
    # Whether the class is used as the range of another class in the schema.
    attribute :nested, Valkyrie::Types::Strict::Bool.default(false)
  end
end
