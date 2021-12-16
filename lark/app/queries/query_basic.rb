# frozen_string_literal: true

module Queries
  ##
  # A base class with common behavior for Sequel adapter custom queries
  class QueryBasic
    ##
    # @!attribute [r] query_service
    #   @return [#custom_queries]
    attr_reader :query_service

    delegate :connection, to: :query_service
    delegate :resource_factory, to: :query_service

    ##
    # @param query_service [#custom_queries]
    def initialize(query_service:)
      @query_service = query_service
    end
  end
end
