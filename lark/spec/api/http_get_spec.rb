# frozen_string_literal: true

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
    let(:persister)  { adapter.persister }
    let(:pref_label) { ['Moomin'] }
    let(:resource)   { Concept.new(id: id, pref_label: pref_label) }
    let(:response_expected) do
      JSON.dump(pref_label: pref_label,
                alternate_label: [],
                hidden_label: [],
                exact_match: [],
                close_match: [],
                note: [],
                scope_note: [],
                editorial_note: [],
                history_note: [],
                definition: [],
                scheme: 'http://www.w3.org/2004/02/skos/core#ConceptScheme',
                literal_form: [],
                label_source: [],
                campus: [],
                annotation: [],
                id: id)
    end

    let(:adapter) do
      Valkyrie::MetadataAdapter.find(Lark.config.index_adapter)
    end

    before { persister.save(resource: resource) }

    after  { persister.wipe! }

    it 'gives a 200' do
      get "/#{id}"

      expect(last_response.status).to eq 200
    end

    it 'gets the object matching the id' do
      get "/#{id}"

      expect(last_response.body)
        .to eq response_expected
    end
  end

  context 'with basic term search exact match' do
    let(:adapter) do
      Valkyrie::MetadataAdapter.find(Lark.config.index_adapter)
    end
    let(:persister) { adapter.persister }
    let(:pref_label_1) { 'authority 1' }
    let(:pref_label_alternate) { 'alternate authority' }
    let(:alternate_label) { 'alternate label' }

    before do
      FactoryBot.create(:concept, pref_label: ['authority 1'])
      FactoryBot.create(:concept, pref_label: ['alternate authority'],
                                  alternate_label: ['alternate label'])
    end

    after { persister.wipe! }

    context 'with unsupported search term' do
      it 'gives a 400 bad request' do
        get '/search', any_term: 'any term'

        expect(last_response.status).to eq 400
      end
    end

    context 'with no results' do
      it 'gives a 404 with term pref_label' do
        get '/search', pref_label: 'authority'

        expect(last_response.status).to eq 404
      end

      it 'gives a 404 with term alternate_label' do
        get '/search', alternate_label: 'authority'

        expect(last_response.status).to eq 404
      end
    end

    context 'with term matched pref_label' do
      it 'gives a 200' do
        get '/search', pref_label: pref_label_1

        expect(last_response.status).to eq 200
      end

      it 'contains the existing authority with pre_label matched' do
        get '/search', pref_label: pref_label_1

        expect(JSON.parse(last_response.body).first.symbolize_keys)
          .to include(pref_label: [pref_label_1], alternate_label: [])
      end
    end

    context 'with term match alternate_label' do
      it 'gives a 200' do
        get '/search', alternate_label: alternate_label

        expect(last_response.status).to eq 200
      end

      it 'contains the existing authority with alternate_label matched' do
        get '/search', alternate_label: alternate_label

        expect(JSON.parse(last_response.body).first.symbolize_keys)
          .to include(pref_label: [pref_label_alternate],
                      alternate_label: [alternate_label])
      end
    end
  end
end
