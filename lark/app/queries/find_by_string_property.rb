# frozen_string_literal: true

module Queries
  ##
  # Custom query to search authorities by string property
  # @example search with a string property
  #   FindByStringProperty.new(query_service: query_service)
  #                       .find_by_string_property(property: pref_label,
  #                                                value: 'label')
  class FindByStringProperty < QueryBasic
    # Access the list of methods exposed for the query
    # @return [Array<Symbol>] query method signatures
    def self.queries
      [:find_by_string_property]
    end

    def find_by_string_property(property:, value:)
      run_query(property, value)
    end

    private

    ##
    # build the query
    # @param property [String] the property the resources
    # @param value [String] the value of the property
    def query(property, value)
      "#{property}_ssim:\"#{value}\""
    end

    ##
    # Iterate through the results of the solr query for all paging results.
    # @param query [String] the solr query
    # @yield [Resource] a resource with property that match the value
    def solr_search(query)
      docs = Valkyrie::Persistence::Solr::Queries::DefaultPaginator.new
      while docs.has_next?
        results = connection.paginate(docs.next_page, docs.per_page, "select",
          params: {q: query})
        docs = results["response"]["docs"]
        docs.each do |doc|
          yield resource_factory.to_resource(object: doc)
        end
      end
    end

    ##
    # Execute the query
    # @param property [String] the property the resources
    # @param value [String] the value of the property
    def run_query(property, value)
      enum_for(:solr_search, query(property, value))
    end
  end
end
