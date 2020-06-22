# frozen_string_literal: true

require 'spec_helper'
require 'rack/test'
require 'timecop'
require_relative '../../config/environment'

RSpec.describe 'GET /healthz' do
  include ::Rack::Test::Methods

  let(:app) { Lark.application }
  let(:index_conn) { Lark::HealthChecks::IndexConnection }
  let(:solr_conn) { Lark::HealthChecks::SolrConnection }
  let(:pg_conn) { Lark::HealthChecks::PostgresConnection }

  describe '/complete' do
    context 'when using memory for index adapter' do
      before do
        allow(Lark.config).to receive(:index_adapter).and_return(:memory)
      end

      it 'returns success' do
        get '/healthz/complete'

        expect(last_response).to have_attributes status: 200
      end
    end

    context 'when using memory for event adapter' do
      before do
        allow(Lark.config).to receive(:event_adapter).and_return(:memory)
      end

      it 'returns success' do
        get '/healthz/complete'

        expect(last_response).to have_attributes status: 200
      end
    end

    context 'when services are healthy' do
      before do
        allow_any_instance_of(solr_conn).to receive(:status).and_return(true)
        allow_any_instance_of(pg_conn).to receive(:status).and_return(true)
      end

      it 'returns success' do
        get '/healthz/complete'

        expect(last_response).to have_attributes status: 200
      end
    end

    context 'when services are not healthy' do
      let(:response) do
        {
          name: 'Lark',
          status: false,
          version: '0.1.0',
          checks: [{
            name: 'index',
            type: 'DATABASE',
            status: false,
            optional: false,
            time: 0.0
          }, {
            name: 'solr',
            type: 'INTERNAL_SERVICE',
            url: ENV['SOLR_URL'],
            status: false,
            optional: false,
            time: 0.0
          }, {
            name: 'postgres',
            type: 'DATABASE',
            status: false,
            optional: false,
            time: 0.0
          }]
        }
      end

      before do
        Timecop.freeze(Time.now)

        allow_any_instance_of(index_conn).to receive(:status).and_return(false)
        allow_any_instance_of(solr_conn).to receive(:status).and_return(false)
        allow_any_instance_of(pg_conn).to receive(:status).and_return(false)

        get '/healthz/complete'
      end

      after do
        Timecop.return
      end

      it 'responds with a 500 status code' do
        expect(last_response.status).to eq 500
      end

      it 'responds with a json result' do
        json_response = JSON.parse(last_response.body, symbolize_names: true)
        expect(json_response).to eq(response)
      end
    end
  end
end
