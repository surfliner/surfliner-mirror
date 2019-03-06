# frozen_string_literal: true

##
# A simple controller that resolves requests for authority records.
class BatchController < BaseController
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
