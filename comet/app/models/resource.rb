# frozen_string_literal: true

##
# Base resource class for those classes defined in M3.
class Resource < Hyrax::Work
  attribute :ark, Valkyrie::Types::ID
end
