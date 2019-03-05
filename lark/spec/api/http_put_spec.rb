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

      expect(last_response.body)
        .to eq JSON.dump(id: id, pref_label: 'PrefLabel')
    end

    it 'with PUT responds 204 no_content status' do
      put "/#{id}", data, 'CONTENT_TYPE' => ctype

      expect(last_response.status).to eq 204
    end

    context 'with PUT to update the concept' do
      let(:new_label) { 'Label edited' }

      before do
        put "/#{id}", data, 'CONTENT_TYPE' => ctype
      end

      it 'update the prefLabel' do
        get "/#{id}"

        expect(last_response.body)
          .to eq JSON.dump(id: id, pref_label: new_label)
      end
    end
  end

  context 'when putting unknown formats' do
    let(:ctype) { 'application/fake' }
    let(:data)  { '' }

    it 'responds with a 415 status code' do
      post '/', data, 'CONTENT_TYPE' => ctype

      expect(last_response.status).to eq 415
    end
  end

  context 'when putting batch of authorities in JSON' do
    let(:authority_1) do
      FactoryBot.create(:concept, pref_label: ['Label 1'])
    end

    let(:authority_2) do
      FactoryBot.create(:concept, pref_label: 'Label 2')
    end

    let(:ctype) { 'application/json' }
    let(:data)  do
      [{ id: authority_1.id.to_s, pref_label: 'new_label_1' },
       { id: authority_2.id.to_s, pref_label: 'new_label_2' }].to_json
    end

    it 'responds with a 204 status code' do
      put '/batch_edit', data, 'CONTENT_TYPE' => ctype

      expect(last_response.status).to eq 204
    end

    context 'with PUT to update the concept' do
      before do
        put '/batch_edit', data, 'CONTENT_TYPE' => ctype
      end

      it 'update the Label for authority_1' do
        get "/#{authority_1.id}"

        expect(last_response.body)
          .to eq JSON.dump(id: authority_1.id, pref_label: 'new_label_1')
      end

      it 'update the Label for authority_2' do
        get "/#{authority_2.id}"

        expect(last_response.body)
          .to eq JSON.dump(id: authority_2.id, pref_label: 'new_label_2')
      end
    end

    context 'when putting unknown formats' do
      let(:ctype) { 'application/fake' }
      let(:data)  { '' }

      it 'responds with a 415 status code' do
        put '/batch_edit', data, 'CONTENT_TYPE' => ctype

        expect(last_response.status).to eq 415
      end
    end
  end
end
