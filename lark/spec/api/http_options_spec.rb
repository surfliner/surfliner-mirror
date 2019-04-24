# frozen_string_literal: true

require 'spec_helper'
require 'rack/test'
require_relative '../../config/environment'

RSpec.describe 'OPTIONS' do
  include ::Rack::Test::Methods

  let(:app) { Lark.application }

  context 'with POSTing root CORS preflight' do
    before { options '/' }

    it 'gives 204 status' do
      expect(last_response.status).to eq 204
    end

    it 'has header that allows CORS request' do
      expect(last_response.headers)
        .to include 'Access-Control-Allow-Origin' => '*'
    end

    it 'has header for allow methods' do
      expect(last_response.headers)
        .to include 'Access-Control-Allow-Methods' => 'POST, OPTIONS'
    end

    it 'has header Access-Control-Allow-Headers for Content-Type' do
      expect(last_response.headers)
        .to include 'Access-Control-Allow-Headers' => 'Content-Type'
    end

    it 'has header for Access-Control-Max-Age' do
      expect(last_response.headers)
        .to include 'Access-Control-Max-Age' => '86400'
    end
  end

  context 'with POSTing /batch_edit CORS preflight' do
    before { options '/batch_edit' }

    it 'gives 204 status' do
      expect(last_response.status).to eq 204
    end

    it 'has header that allows CORS request' do
      expect(last_response.headers)
        .to include 'Access-Control-Allow-Origin' => '*'
    end

    it 'has header for allowing methods' do
      expect(last_response.headers)
        .to include 'Access-Control-Allow-Methods' => 'POST, OPTIONS'
    end

    it 'has header Access-Control-Allow-Headers for Content-Type' do
      expect(last_response.headers)
        .to include 'Access-Control-Allow-Headers' => 'Content-Type'
    end

    it 'has header for Access-Control-Max-Age' do
      expect(last_response.headers)
        .to include 'Access-Control-Max-Age' => '86400'
    end
  end

  context 'with PUTting /:id CORS preflight' do
    let(:adapter) do
      Valkyrie::MetadataAdapter.find(Lark.config.index_adapter)
    end
    let(:persister) { adapter.persister }
    let(:allowed_methods) { 'POST, GET, PUT, OPTIONS, DELETE' }
    let(:id) { 'a_fake_id' }

    before do
      FactoryBot.create(:concept,
                        id: id,
                        pref_label: ['A PrefLabel'])

      options "/#{id}"
    end

    after { persister.wipe! }

    it 'gives 204 status' do
      expect(last_response.status).to eq 204
    end

    it 'has header that allows CORS request' do
      expect(last_response.headers)
        .to include 'Access-Control-Allow-Origin' => '*'
    end

    it 'has header for allowing methods' do
      expect(last_response.headers)
        .to include 'Access-Control-Allow-Methods' => allowed_methods
    end

    it 'has header Access-Control-Allow-Headers for Content-Type' do
      expect(last_response.headers)
        .to include 'Access-Control-Allow-Headers' => 'Content-Type'
    end

    it 'has header for Access-Control-Max-Age' do
      expect(last_response.headers)
        .to include 'Access-Control-Max-Age' => '86400'
    end
  end
end
