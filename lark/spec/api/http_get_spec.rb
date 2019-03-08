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
end
