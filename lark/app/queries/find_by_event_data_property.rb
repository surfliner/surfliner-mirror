# frozen_string_literal: true

module Queries
  ##
  # Custom query to search events by authority id in :data field in SQL
  # @example search with a string property
  #   FindByEventDataProperty.new(query_service: query_service)
  #                          .find_by_event_data_property(property: pref_label,
  #                                                       value: 'label')
  class FindByEventDataProperty < QueryBasic
    # Access the list of methods exposed for the query
    # @return [Array<Symbol>] query method signatures
    def self.queries
      [:find_by_event_data_property]
    end

    def find_by_event_data_property(property:, value:)
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
      metadata @> '{"data": [{\"#{property}\": \"#{value}\"}]}'
      ORDER BY created_at
      SQL
    end

    ##
    # Execute the query
    # @param property [String] the property the resources
    # @param value [String] the value of the property
    def run_query(property, value)
      @query_service.run_query(query(property, value))
    end
  end
end
