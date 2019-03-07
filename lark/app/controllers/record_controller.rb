# frozen_string_literal: true

require_relative 'concerns/record_controller_behavior'

##
# A simple controller that resolves requests for authority records.
class RecordController
  include RecordControllerBehavior

  ##
  # Creates a new authority record from the request
  def create
    record = Lark::Transactions::CreateAuthority
             .new(event_stream: event_stream)
             .call(attributes: parsed_body(format: ctype))
             .value!

    [201, response_headers, [serialize(record: record, format: ctype)]]
  rescue JSON::ParserError => err
    [400, {}, [err.message]]
  rescue Lark::RequestError => err
    [err.status, {}, [err.message]]
  end

  ##
  # https://dry-rb.org/gems/dry-view/
  def show
    record = query_service.find_by(id: params['id'])

    [200, {}, [serialize(record: record, format: 'application/json')]]
  rescue Valkyrie::Persistence::ObjectNotFoundError => err
    [404, {}, [err.message]]
  end

  ##
  # Update an existing authority record from the request
  def update
    attrs = parsed_body(format: ctype)

    Lark::Transactions::UpdateAuthority
      .new(event_stream: event_stream, adapter: adapter)
      .call(id: params['id'], attributes: attrs)

    [204, response_headers, []]
  rescue Lark::RequestError => err
    [err.status, {}, [err.message]]
  end
end
