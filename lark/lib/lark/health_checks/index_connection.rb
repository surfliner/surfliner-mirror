# frozen_string_literal: true

require "rack/healthcheck/checks/base"
require "rack/healthcheck/type"

module Lark
  module HealthChecks
    ##
    # @see https://github.com/downgba/rack-healthcheck#rackhealthcheck
    class IndexConnection < Rack::Healthcheck::Checks::Base
      TYPE = Rack::Healthcheck::Type::DATABASE

      ##
      # @param name   [String]
      # @param config [Hash<Symbol, Object>]
      def initialize(name, config = {})
        super(name, TYPE, config[:optional], config[:url])
      end

      private

      def check
        Lark::Indexer.new
        @status = true
      rescue => _e
        @status = false
      end
    end
  end
end
