# frozen_string_literal: true

require_relative 'application_controller'
require_relative 'concerns/record_controller_behavior'

##
# A controller that resolves requests for handling batch of authority records.
class BatchController < ApplicationController
  include RecordControllerBehavior

  ##
  # Update an existing authority record from the request
  def batch_update
    authorities = parsed_body(format: ctype)
    authorities.each do |attrs|
      Lark::Transactions::UpdateAuthority
        .new(event_stream: event_stream, adapter: adapter)
        .call(id: attrs[:id],
              attributes: attrs)
    end

    [204, response_headers, []]
  rescue Lark::RequestError => err
    [err.status, {}, [err.message]]
  end
end
