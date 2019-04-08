# frozen_string_literal: true

Rack::Healthcheck.configure do |config|
  config.app_name = 'Lark'
  config.app_version = 1.0
  config.checks = [
    Rack::Healthcheck::Checks::HTTPRequest.new('api', config = {
      url: 'http://localhost:5000',
      service_type: 'INTERNAL_SERVICE',
      headers: {'Host' => 'localhost'},
      expected_result: 'LIVE'
    }),
    Rack::Healthcheck::Checks::HTTPRequest.new('solr', config = {
      url: 'http://solr:8983/solr',
      service_type: 'INTERNAL_SERVICE',
      headers: {'Host' => 'localhost'},
      expected_result: 'LIVE'
    })
  ]
end