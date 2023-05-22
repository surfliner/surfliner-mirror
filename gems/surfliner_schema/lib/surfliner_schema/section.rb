# frozen_string_literal: true

module SurflinerSchema
  ##
  # A sectioning division of properties within a resource.
  class Section < Dry::Struct
    ##
    # The internal name used for the section.
    attribute :name, Valkyrie::Types::Coercible::Symbol

    ##
    # The human‐readable display label for the section.
    attribute :display_label, Valkyrie::Types::Coercible::String
  end
end
