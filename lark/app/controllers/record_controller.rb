# frozen_string_literal: true

require_relative 'concerns/record_controller_behavior'

##
# A simple controller that resolves requests for authority records.
class RecordController < ApplicationController
  include RecordControllerBehavior

  ##
  # options for CORS preflight request
  # Access-Control-Allow-Methods: POST, GET, PUT, OPTIONS, DELETE.
  # Access-Control-Allow-Headers: Content-Type
  # Access-Control-Max-Age: 86400 (delta seconds, 24 hours)
  def options
    response_headers = {
      'Access-Control-Allow-Methods' => 'POST, GET, PUT, OPTIONS, DELETE',
      'Access-Control-Allow-Headers' => 'Content-Type',
      'Access-Control-Max-Age' => '86400'
    }

    [204, response_headers.merge(cors_allow_header), []]
  end

  ##
  # Creates a new authority record from the request
  def create
    with_error_handling do
      result = Lark::Transactions::CreateAuthority
               .new(event_stream: event_stream)
               .call(attributes: parsed_body(format: ctype))
      record = result.value_or { |failure| raise_error_for(failure) }

      [201, response_headers, [serialize(record: record, format: ctype)]]
    end
  end

  ##
  # https://dry-rb.org/gems/dry-view/
  def show
    record = query_service.find_by(id: params['id'])

    data = serialize(record: record, format: 'application/json')
    [200, response_headers, [data]]
  rescue Valkyrie::Persistence::ObjectNotFoundError => e
    [404, cors_allow_header, [e.message]]
  end

  ##
  # Update an existing authority record from the request
  def update
    with_error_handling do
      attrs = parsed_body(format: ctype)

      result = Lark::Transactions::UpdateAuthority
               .new(event_stream: event_stream, adapter: adapter)
               .call(id: params['id'], attributes: attrs)
      record = result.value_or { |failure| raise_error_for(failure) }

      [200, cors_allow_header, [serialize(record: record, format: ctype)]]
    end
  end
end
