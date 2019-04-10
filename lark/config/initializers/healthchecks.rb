# frozen_string_literal: true

require_relative '../../lib/lark/health_checks/index_connection'
require_relative '../../lib/lark/health_checks/solr_connection'

Rack::Healthcheck.configure do |config|
  config.app_name = 'Lark'
  config.app_version = Lark::VERSION
  config.checks = [
    Lark::HealthChecks::IndexConnection.new('index'),
    Lark::HealthChecks::SolrConnection.new('solr', url: ENV['SOLR_URL'])
  ]
end
