# frozen_string_literal: true

##
# Basic class for custom queries
class QueryBasic
  attr_reader :query_service
  delegate :connection, to: :query_service
  delegate :resource_factory, to: :query_service

  def initialize(query_service:)
    @query_service = query_service
  end
end
