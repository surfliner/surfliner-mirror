# frozen_string_literal: true

require "valkyrie"

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
  end
end
