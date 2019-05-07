# frozen_string_literal: true

require 'rack/healthcheck/checks/base'
require 'rack/healthcheck/type'

module Lark
  module HealthChecks
    ##
    # @see https://github.com/downgba/rack-healthcheck#rackhealthcheck
    class PostgresConnection < Rack::Healthcheck::Checks::Base
      TYPE = Rack::Healthcheck::Type::DATABASE

      ##
      # @param name   [String]
      # @param config [Hash<Symbol, Object>]
      def initialize(name, config = {})
        super(name, TYPE, config[:optional], config[:url])
      end

      private

      def check
        Sequel.connect(DATABASE)
        @status = true
      rescue Sequel::DatabaseError => _
        @status = false
      end
    end
  end
end
