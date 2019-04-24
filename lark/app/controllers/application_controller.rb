# frozen_string_literal: true

##
# An abstract controller encapsulating application-wide controller behavior
class ApplicationController
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

  protected

  def with_error_handling
    yield if block_given?
  rescue Lark::RequestError => e
    [e.status, cors_allow_header, [e.message]]
  end

  def response_headers
    { 'Content-Type' => 'application/json' }.merge(cors_allow_header)
  end

  ##
  # The header to support CORS
  def cors_allow_header
    { 'Access-Control-Allow-Origin' => '*' }
  end
end
