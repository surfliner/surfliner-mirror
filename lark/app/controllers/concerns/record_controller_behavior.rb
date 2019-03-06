# frozen_string_literal: true

##
# base module for resolving requests for authority records.
module RecordControllerBehavior
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
