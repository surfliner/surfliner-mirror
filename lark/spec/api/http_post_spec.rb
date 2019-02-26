# frozen_string_literal: true

require 'spec_helper'
require 'rack/test'

require_relative '../../config/environment'

RSpec.describe 'POST /' do
  include ::Rack::Test::Methods

  let(:app) { Lark.application }

  context 'when posting JSON' do
    let(:ctype)         { 'application/json' }
    let(:data)          { { prefLabel: 'moomin' }.to_json }
    let(:query_service) { adapter.query_service }

    let(:adapter) do
      Valkyrie::MetadataAdapter.find(Lark.config.index_adapter)
    end

    it 'responds 201' do
      post '/', data, 'CONTENT_TYPE' => ctype

      expect(last_response.status).to eq 201 # created
    end

    it 'returns a JSON body' do
      post '/', data, 'CONTENT_TYPE' => ctype

      expect(last_response.headers)
        .to include 'Content-Type' => ctype
    end

    it 'creates an id' do
      post '/', data, 'CONTENT_TYPE' => ctype

      expect(JSON.parse(last_response.body))
        .to match 'id' => an_instance_of(String)
    end

    it 'creates a concept' do
      expect { post '/', data, 'CONTENT_TYPE' => ctype }
        .to change { query_service.find_all.count }
        .by 1
    end
  end
end
