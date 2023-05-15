# frozen_string_literal: true

##
# Generic Valkyrie resource class with additional attributes
module Superskunk
  class Resource < Valkyrie::Resource
    # § Defined by Hyrax::Resource:
    attribute :alternate_ids, Valkyrie::Types::Array.of(Valkyrie::Types::ID)

    # § Defined by Hyrax::Work:
    attribute :title, Valkyrie::Types::Array.of(Valkyrie::Types::String)
    attribute :date_modified,
      Valkyrie::Types::Array.of(Valkyrie::Types::DateTime)
    attribute :date_uploaded,
      Valkyrie::Types::Array.of(Valkyrie::Types::DateTime)
    attribute :member_of_collection_ids, Valkyrie::Types::Set.of(Valkyrie::Types::ID)

    # § Defined by Comet:
    attribute :ark, Valkyrie::Types::ID

    ##
    # @return [Boolean] true
    def work?
      true
    end
  end
end
