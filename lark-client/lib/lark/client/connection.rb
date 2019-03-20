# frozen_string_literal: true

require 'net/http'

module Lark
  module Client
    ##
    # An HTTP connection for the Lark REST API
    class Connection
      ##
      # @!attribute [rw] server_url
      #   @return [URI]
      attr_accessor :server_url

      ##
      # @param server_url [URI, String]
      def initialize(server_url:)
        self.server_url =
          case server_url
          when URI
            server_url
          when String
            URI(server_url)
          else
            raise ArgumentError, "Expected URI or String; got #{server_url}"
          end
      end

      ##
      # @param data [String] a JSON string
      #
      # @return [Net::HTTPResponse]
      def create(data:, headers: {})
        Net::HTTP.post(server_url, data, headers)
      end
    end
  end
end
