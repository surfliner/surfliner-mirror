# frozen_string_literal: true

##
# A simple controller that resolves requests for authority records.
class RecordController
  ##
  # @!attribute [r] params
  #   @return [Hash<String, String>]
  # @!attribute [r] request
  #   @return [Rack::Request]
  attr_reader :params, :request

  ##
  # @param params  [Hash<String, String>]
  # @param request [Rack::Request]
  def initialize(params: nil, request: nil, config: Lark.config)
    @config  = config
    @params  = params
    @request = request
  end

  ##
  # Creates a new authority record from the request
  def create
    record = Lark::Transactions::CreateAuthority
             .new(event_stream: event_stream)
             .call(attributes: parsed_body(format: ctype))
             .value!

    [201, response_headers, [serialize(record: record, format: ctype)]]
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

  ##
  # Update an existing authority record from the request
  def batch_update
    authorities = parsed_body(format: ctype)
    authorities.each do |attrs|
      Lark::Transactions::UpdateAuthority.new(event_stream: event_stream)
                                         .call(id: attrs[:id],
                                               attributes: attrs,
                                               adapter: adapter)
    end

    [204, response_headers, []]
  rescue Lark::RequestError => err
    [err.status, {}, [err.message]]
  end

  private

  def adapter
    Valkyrie::MetadataAdapter.find(@config.index_adapter)
  end

  def event_stream
    @config.event_stream
  end

  def ctype
    request.env['CONTENT_TYPE']
  end

  def parsed_body(format:)
    Lark::RecordParser
      .for(content_type: format)
      .parse(request.body)
  end

  def response_headers
    { 'Content-Type' => 'application/json' }
  end

  def serialize(record:, format:)
    Lark::RecordSerializer
      .for(content_type: format)
      .serialize(record: record)
  end

  def query_service
    adapter.query_service
  end
end
