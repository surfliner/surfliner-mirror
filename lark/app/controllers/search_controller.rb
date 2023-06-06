# frozen_string_literal: true

##
# A controller that resolves searching of authority records.
class SearchController < ApplicationController
  include RecordControllerBehavior

  ##
  # exact search for known terms: pref_label, alternate_label
  def exact_search
    with_error_handling do
      return [400, response_headers, ["Unknown search term."]] if
        search_term(params).empty?

      rs = search params

      return [404, cors_allow_header, []] if rs.count.zero?

      data = serialize(record: rs, format: "application/json")
      [200, response_headers, [data]]
    end
  end

  private

  ##
  # Retrieve the term that is supported for searching.
  # An empty string will be return when no supported terms found.
  # @param params [Hash] the request parameters map
  def search_term(params)
    return "" unless params.key?("pref_label") || params.key?("alternate_label")

    params.key?("pref_label") ? "pref_label" : "alternate_label"
  end

  ##
  # @override serialize(record:, format:)
  # Serialized an array of authority records
  def serialize(record:, format:)
    buf = StringIO.new
    buf << "["

    record.each do |re|
      buf << "," if buf.size > 1

      buf << Lark::RecordSerializer
        .for(content_type: format)
        .serialize(record: re)
    end

    buf << "]"

    buf.string
  end

  ##
  # perform basic term search
  # @params [Hash] the request parameters map
  def search(params)
    label = search_term(params)
    query_service.custom_queries
      .find_by_string_property(property: label,
        value: params[label])
  end
end
