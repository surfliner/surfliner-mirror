# frozen_string_literal: true

require_relative 'application_controller'
require_relative 'concerns/record_controller_behavior'

##
# A controller that resolves requests for handling batch of authority records.
class BatchController < ApplicationController
  include RecordControllerBehavior

  ##
  # options for CORS preflight request
  # Access-Control-Allow-Methods: POST, OPTIONS.
  # Access-Control-Allow-Headers: Content-Type
  # Access-Control-Max-Age: 86400 (delta seconds, 24 hours)
  def options
    response_headers = {
      'Access-Control-Allow-Methods' => 'POST, OPTIONS',
      'Access-Control-Allow-Headers' => 'Content-Type',
      'Access-Control-Max-Age' => '86400'
    }

    [204, response_headers.merge(cors_allow_header), []]
  end

  ##
  # Update an existing authority record from the request
  def batch_update
    with_error_handling do
      authorities = parsed_body(format: ctype)
      authorities.each do |attrs|
        Lark::Transactions::UpdateAuthority
          .new(event_stream: event_stream, adapter: adapter)
          .call(id: attrs[:id],
                attributes: attrs)
      end

      [204, cors_allow_header, []]
    end
  end
end
