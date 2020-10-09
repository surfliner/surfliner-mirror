# frozen_string_literal: true

##
# Custom query to search events by event property in SQL
# @example search with an event property
#   FindByStringProperty.new(query_service: query_service)
#                       .find_by_event_property(property: :type,
#                                               value: :create)
class FindByEventProperty < FindByEventDataProperty
  # Access the list of methods exposed for the query
  # @return [Array<Symbol>] query method signatures
  def self.queries
    [:find_by_event_property]
  end

  def find_by_event_property(property:, value:)
    run_query(property, value)
  end

  private

  ##
  # build the query
  # @param property [String] the property the resources
  # @param value [String] the value of the property
  def query(property, value)
    <<-SQL
      select * FROM orm_resources WHERE
      metadata @> '{\"#{property}\": [\"#{value}\"]}'
      ORDER BY created_at
    SQL
  end
end
