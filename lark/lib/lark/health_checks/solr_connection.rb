# frozen_string_literal: true

require 'rack/healthcheck/checks/base'
require 'rack/healthcheck/type'
require 'net/http'
require 'uri'

module Lark
  module HealthChecks
    ##
    # @see https://github.com/downgba/rack-healthcheck#rackhealthcheck
    class SolrConnection < Rack::Healthcheck::Checks::Base
      TYPE = Rack::Healthcheck::Type::INTERNAL_SERVICE
      ##
      # @param name   [String]
      # @param config [Hash<Symbol, Object>]
      def initialize(name, config = {})
        super(name, TYPE, config[:optional], config[:url])
      end

      private

      def check
        uri = URI(url)
        http = Net::HTTP.new(uri.host, uri.port)
        response = http.get('/')
        @status = response.code == '302'
      rescue StandardError => _
        @status = false
      end
    end
  end
end
