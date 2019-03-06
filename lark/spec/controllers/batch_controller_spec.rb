# frozen_string_literal: true

require 'spec_helper'
require_relative '../../config/environment'

RSpec.describe BatchController do
  let(:adapter) do
    Valkyrie::MetadataAdapter.find(Lark.config.index_adapter)
  end
  let(:persister) { adapter.persister }

  let(:headers) { { 'CONTENT_TYPE' => 'application/json' } }

  let(:request) do
    instance_double(Rack::Request,
                    body: body,
                    env: headers)
  end

  describe '#batch_update' do
    subject(:controller) do
      described_class.new(request: request)
    end

    let(:authority_1) do
      persister.save(resource: Concept.new(pref_label: 'Label 1'))
    end
    let(:authority_2) do
      persister.save(resource: Concept.new(pref_label: 'Label 2'))
    end

    context 'with an unknown media type' do
      let(:headers) { { 'CONTENT_TYPE' => 'application/fake' } }
      let(:body) { StringIO.new('') }

      it 'gives a 415 status' do
        expect(controller.batch_update.first).to eq 415
      end
    end

    context 'with batch of existing authority records' do
      let(:data)  do
        [{ id: authority_1.id.to_s, pref_label: 'new_label_1' },
         { id: authority_2.id.to_s, pref_label: 'new_label_2' }].to_json
      end
      let(:body) { StringIO.new(data) }

      it 'gives a 204 no_content status' do
        expect(controller.batch_update.first).to eq 204
      end
    end
  end
end
