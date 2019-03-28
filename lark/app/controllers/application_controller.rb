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
end
