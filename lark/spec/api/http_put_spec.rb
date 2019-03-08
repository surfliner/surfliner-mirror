# frozen_string_literal: true

require 'spec_helper'
require 'rack/test'

require_relative '../../config/environment'

RSpec.describe 'PUT /{id}' do
  include ::Rack::Test::Methods

  let(:app) { Lark.application }

  context 'when putting JSON' do
    let(:authority) do
      FactoryBot.create(:concept, pref_label: ['PrefLabel'])
    end

    let(:id)            { authority.id.to_s }
    let(:ctype)         { 'application/json' }
    let(:data)          { { pref_label: new_label }.to_json }
    let(:new_label)     { 'label' }
    let(:query_service) { adapter.query_service }

    it 'verify concept with PrefLabel exists' do
      get "/#{id}"

      expect(JSON.parse(last_response.body).symbolize_keys)
        .to include(id: id, pref_label: ['PrefLabel'])
    end

    it 'with PUT responds 204 no_content status' do
      put "/#{id}", data, 'CONTENT_TYPE' => ctype

      expect(last_response.status).to eq 204
    end

    context 'with PUT to update the concept' do
      let(:new_label) { ['Label edited'] }

      before do
        put "/#{id}", data, 'CONTENT_TYPE' => ctype
      end

      it 'update the prefLabel' do
        get "/#{id}"

        expect(JSON.parse(last_response.body).symbolize_keys)
          .to include(id: id, pref_label: new_label)
      end
    end

    context 'when putting unknown formats' do
      let(:ctype) { 'application/fake' }
      let(:data)  { '' }
      let(:authority) do
        FactoryBot.create(:concept, pref_label: ['PrefLabel'])
      end

      it 'responds with a 415 status code' do
        put "/#{authority.id}", data, 'CONTENT_TYPE' => ctype

        expect(last_response.status).to eq 415
      end
    end
  end
end
