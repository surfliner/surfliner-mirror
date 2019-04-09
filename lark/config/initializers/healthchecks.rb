# frozen_string_literal: true

require_relative '../../lib/lark/health_checks/index_connection'

Rack::Healthcheck.configure do |config|
  config.app_name = 'Lark'
  config.app_version = Lark::VERSION
  config.checks = [
    Lark::HealthChecks::IndexConnection.new('index')
  ]
end
