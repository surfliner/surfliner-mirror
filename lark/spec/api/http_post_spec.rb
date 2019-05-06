# frozen_string_literal: true

require 'spec_helper'
require 'rack/test'

require_relative '../../config/environment'

RSpec.describe 'POST /' do
  include ::Rack::Test::Methods

  let(:app) { Lark.application }
  let(:adapter) do
    Valkyrie::MetadataAdapter.find(Lark.config.index_adapter)
  end
  let(:persister) { adapter.persister }

  before  { persister.wipe! }

  context 'when posting JSON' do
    let(:ctype)         { 'application/json' }
    let(:data)          { { pref_label: 'moomin' }.to_json }
    let(:query_service) { adapter.query_service }

    before { post '/', data, 'CONTENT_TYPE' => ctype }

    it 'responds 201' do
      expect(last_response.status).to eq 201 # created
    end

    it 'returns a JSON body' do
      expect(last_response.headers)
        .to include 'Content-Type' => ctype
    end

    it 'creates an id' do
      expect(JSON.parse(last_response.body))
        .to include 'id' => an_instance_of(String)
    end

    it 'has header for CORS request' do
      expect(last_response.headers)
        .to include 'Access-Control-Allow-Origin' => '*'
    end

    it 'creates a concept' do
      expect { post '/', data, 'CONTENT_TYPE' => ctype }
        .to change { query_service.find_all.count }
        .by 1
    end
  end

  context 'when posting unknown formats' do
    let(:ctype) { 'application/fake' }
    let(:data)  { '' }

    before { post '/', data, 'CONTENT_TYPE' => ctype }

    it 'responds with a 415 status code' do
      expect(last_response.status).to eq 415
    end

    it 'has header for CORS request' do
      expect(last_response.headers)
        .to include 'Access-Control-Allow-Origin' => '*'
    end
  end

  context 'when posting to update batch of authorities in JSON' do
    let(:authority_1) do
      persister.save(resource: FactoryBot.create(:concept,
                                                 id: 'a_test_id1',
                                                 pref_label: 'Label 1'))
    end

    let(:authority_2) do
      persister.save(resource: FactoryBot.create(:concept,
                                                 id: 'a_test_id2',
                                                 pref_label: 'Label 2'))
    end

    let(:ctype) { 'application/json' }
    let(:data)  do
      [{ id: authority_1.id.to_s, pref_label: 'new_label_1' },
       { id: authority_2.id.to_s, pref_label: 'new_label_2' }].to_json
    end

    before { post '/batch_edit', data, 'CONTENT_TYPE' => ctype }

    it 'responds with a 204 status code' do
      expect(last_response.status).to eq 204
    end

    it 'has header for CORS request' do
      expect(last_response.headers)
        .to include 'Access-Control-Allow-Origin' => '*'
    end

    context 'with POST to update concepts' do
      before do
        post '/batch_edit', data, 'CONTENT_TYPE' => ctype
      end

      it 'update the Label for authority_1' do
        get "/#{authority_1.id}"

        expect(JSON.parse(last_response.body).symbolize_keys)
          .to include(id: authority_1.id.to_s, pref_label: ['new_label_1'])
      end

      it 'update the Label for authority_2' do
        get "/#{authority_2.id}"

        expect(JSON.parse(last_response.body).symbolize_keys)
          .to include(id: authority_2.id.to_s, pref_label: ['new_label_2'])
      end
    end

    context 'with POSTing to update a non existing concepts' do
      let(:data) { [{ id: 'a_fade_id', pref_label: 'new_label_1' }].to_json }

      before { post '/batch_edit', data, 'CONTENT_TYPE' => ctype }

      it 'returns status 404' do
        expect(last_response.status).to eq 404
      end

      it 'has header for CORS request' do
        expect(last_response.headers)
          .to include 'Access-Control-Allow-Origin' => '*'
      end
    end

    context 'when posting unknown formats' do
      let(:ctype) { 'application/fake' }
      let(:data)  { '' }

      before { post '/batch_edit', data, 'CONTENT_TYPE' => ctype }

      it 'responds with a 415 status code' do
        expect(last_response.status).to eq 415
      end

      it 'has header for CORS request' do
        expect(last_response.headers)
          .to include 'Access-Control-Allow-Origin' => '*'
      end
    end
  end

  context 'when posting malformed JSON' do
    let(:ctype)         { 'application/json' }
    let(:data)          { 'invalid json' }
    let(:message)       { 'unexpected token at \'invalid json\'' }

    before { post '/', data, 'CONTENT_TYPE' => ctype }

    it 'responds with a 400 status code' do
      expect(last_response.status).to eq 400
    end

    it 'responds with a simple message' do
      expect(last_response.body).to include message
    end

    it 'has header for CORS request' do
      expect(last_response.headers)
        .to include 'Access-Control-Allow-Origin' => '*'
    end
  end

  context 'when posting CSV file' do
    let(:ctype)         { 'text/csv' }
    let(:csv_file)      { 'UCSD_authority_sample_2.csv' }
    let(:csv_file_path) { File.join(RSpec.configuration.fixture, csv_file) }
    let(:query_service) { adapter.query_service }
    let(:data) { Rack::Test::UploadedFile.new(csv_file_path, 'text/csv') }

    it 'responds 201' do
      post '/batch_import', data, 'CONTENT_TYPE' => ctype
      expect(last_response.status).to eq 201 # created
    end

    it 'creates three concept' do
      expect { post '/batch_import', data, 'CONTENT_TYPE' => ctype }
        .to change { query_service.find_all_of_model(model: Concept).count }
        .by 3
    end

    context 'with unsupported attributes' do
      let(:csv_file) { 'UCSD_authority_sample_1.csv' }

      before { post '/batch_import', data, 'CONTENT_TYPE' => ctype }

      it 'responds 400' do
        expect(last_response.status).to eq 400
      end
    end
  end
end
