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

    it 'with PUT responds 200 OK status' do
      put "/#{id}", data, 'CONTENT_TYPE' => ctype

      expect(last_response.status).to eq 200
    end

    context 'with PUT to update the concept' do
      let(:new_label) { ['Label edited'] }

      before do
        put "/#{id}", data, 'CONTENT_TYPE' => ctype
      end

      it 'has header for CORS request' do
        expect(last_response.headers)
          .to include 'Access-Control-Allow-Origin' => '*'
      end

      it 'returns the updated pref_label in the body' do
        expect(JSON.parse(last_response.body).symbolize_keys)
          .to include(id: id, pref_label: new_label)
      end

      it 'updates the prefLabel for subsequent GETs' do
        get "/#{id}"

        expect(JSON.parse(last_response.body).symbolize_keys)
          .to include(id: id, pref_label: new_label)
      end

      context 'with disallowed attributes' do
        let(:data) { { pref_label: new_label, updated_at:'2100-01-01' }.to_json }

        it 'gives a 400 error' do
          expect(last_response).to have_attributes status: 400
        end

        it 'returns a meaningful body' do
          expect(last_response.body).to include 'updated_at', 'not allowed'
        end
      end

      context 'with missing attributes' do
        let(:data) { { pref_label: new_label, not_an_attribute: :oh_no }.to_json }

        it 'gives a 400 error' do
          expect(last_response).to have_attributes status: 400
        end

        it 'does not update the record' do
          get "/#{id}"

          expect(JSON.parse(last_response.body).symbolize_keys)
            .to include(id: id, pref_label: ['PrefLabel'])
        end
      end
    end

    context 'with putting to update non-existing record' do
      let(:id)        { 'fake_id' }
      let(:new_label) { ['Label edited'] }

      before { put "/#{id}", data, 'CONTENT_TYPE' => ctype }

      it 'update the prefLabel' do
        expect(last_response.status).to eq 404
      end

      it 'has header for CORS request' do
        expect(last_response.headers)
          .to include 'Access-Control-Allow-Origin' => '*'
      end
    end

    context 'when putting unknown formats' do
      let(:ctype) { 'application/fake' }
      let(:data)  { '' }
      let(:authority) do
        FactoryBot.create(:concept)
      end

      before { put "/#{authority.id}", data, 'CONTENT_TYPE' => ctype }

      it 'responds with a 415 status code' do
        expect(last_response.status).to eq 415
      end

      it 'has header for CORS request' do
        expect(last_response.headers)
          .to include 'Access-Control-Allow-Origin' => '*'
      end
    end
  end
end
