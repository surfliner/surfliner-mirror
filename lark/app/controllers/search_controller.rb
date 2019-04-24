# frozen_string_literal: true

require_relative 'application_controller'
require_relative 'concerns/record_controller_behavior'

##
# A controller that resolves searching of authority records.
class SearchController < ApplicationController
  include RecordControllerBehavior

  ##
  # exact search for known terms: pref_label, alternate_label
  def exact_search
    if search_term(params).empty?
      return [400, response_headers, ['Unknown search term.']]
    end

    rs = search params

    return [404, cors_allow_header, []] if rs.count.zero?

    [200, response_headers, [serialize(record: rs, format: 'application/json')]]
  rescue Lark::RequestError => e
    [e.status, cors_allow_header, [e.message]]
  end

  private

  ##
  # Retrieve the term that is supported for searching.
  # An empty string will be return when no supported terms found.
  # @param params [Hash] the request parameters map
  def search_term(params)
    return '' unless params.key?('pref_label') || params.key?('alternate_label')

    params.key?('pref_label') ? 'pref_label' : 'alternate_label'
  end

  ##
  # @override serialize(record:, format:)
  # Serialized an array of authority records
  def serialize(record:, format:)
    buf = StringIO.new
    buf << '['

    record.each do |re|
      buf << ',' if buf.size > 1

      buf << Lark::RecordSerializer
             .for(content_type: format)
             .serialize(record: re)
    end

    buf << ']'

    buf.string
  end

  ##
  # perform basic term search
  # @params [Hash] the request parameters map
  def search(params)
    label = search_term params
    FindByStringProperty.new(query_service: query_service)
                        .find_by_string_property(property: label,
                                                 value: params[label])
  end
end
