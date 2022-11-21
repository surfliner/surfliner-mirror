# frozen_string_literal: true

require "valkyrie"

module SurflinerSchema
  ##
  # A grouping division of properties within a resource.
  class Grouping < Dry::Struct
    ##
    # The internal name used for the grouping.
    attribute :name, Valkyrie::Types::Coercible::Symbol

    ##
    # The human‐readable display label for the grouping.
    attribute :display_label, Valkyrie::Types::Coercible::String

    ##
    # The human‐readable definition for the grouping.
    attribute :definition,
      Valkyrie::Types::Coercible::String.optional.default(nil)

    ##
    # The human‐readable usage guidelines for the grouping.
    attribute :usage_guidelines,
      Valkyrie::Types::Coercible::String.optional.default(nil)
  end
end
