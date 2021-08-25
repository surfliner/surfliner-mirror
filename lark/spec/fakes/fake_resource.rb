# frozen_string_literal: true

require "valkyrie"

module Lark
  ##
  # A dummy concrete valkyrie resource class for testing
  class FakeResource < Valkyrie::Resource
    attribute :label, Valkyrie::Types::Set
    attribute :note, Valkyrie::Types::Set

    def primary_terms
      %i[label note]
    end
  end
end
