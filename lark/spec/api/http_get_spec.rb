require 'spec_helper'
require 'rack/test'

require_relative '../../config/environment'

RSpec.describe 'GET /{id}' do
  include ::Rack::Test::Methods

  let(:app) { Lark.application }
  let(:id)  { 'a_fake_id' }

  context 'with no object' do
    it 'gives a 404' do
      get "/#{id}"

      expect(last_response.status).to eq 404
    end
  end

  context 'with an existing object' do
    let(:prefLabel) { 'Moomin' }

    before do
      # setup a dummy object with:
      #   id        = id
      #   prefLabel = prefLabel
    end

    it 'gives a 200' do
      get "/#{id}"

      expect(last_response.status).to eq 200
    end

    it 'gets the object matching the id' do
      get "/#{id}"

      expect(last_response.body)
        .to eq JSON.dump(id: id, prefLabel: prefLabel)
    end
  end
end
