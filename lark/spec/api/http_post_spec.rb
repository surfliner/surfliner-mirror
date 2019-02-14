require 'spec_helper'
require 'rack/test'

require_relative '../../config/environment'

RSpec.describe 'POST /' do
  include ::Rack::Test::Methods

  let(:app) { Lark.application }

  context 'when posting JSON' do
    let(:data) { { prefLabel: 'moomin' }.to_json }

    let(:query_service) { adapter.query_service }

    let(:adapter) do
      Valkyrie::MetadataAdapter.find(Lark.config.index_adapter)
    end

    it 'responds 201' do
      post '/', data, 'CONTENT_TYPE' => 'application/json'

      expect(last_response.status).to eq 201 # created
    end

    it 'creates a concept' do
      expect { post '/', data, 'CONTENT_TYPE' => 'application/json' }
        .to change { query_service.find_all.count }
        .by 1
    end
  end
end
