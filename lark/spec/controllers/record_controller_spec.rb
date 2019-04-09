# frozen_string_literal: true

require 'spec_helper'
require_relative '../../config/environment'

RSpec.describe RecordController do
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

  let(:body) { StringIO.new('{}') }

  describe '#create' do
    subject(:controller) { described_class.new(request: request) }

    it 'gives a 201 status' do
      expect(controller.create.first).to eq 201
    end

    context 'with a listener' do
      let(:listener) { FakeListener.new }

      before { Lark.config.event_stream.subscribe(listener) }

      it 'adds an event to the stream' do
        expect { controller.create }
          .to change(listener, :events)
          .to include have_attributes(id: 'created')
      end
    end

    context 'with an unknown media type' do
      let(:headers) { { 'CONTENT_TYPE' => 'application/fake' } }

      it 'gives a 415 status' do
        expect(controller.create.first).to eq 415
      end
    end
  end

  describe '#update' do
    subject(:controller) do
      described_class.new(request: request, params: params)
    end

    let(:authority) do
      persister.save(resource: FactoryBot.create(:concept))
    end
    let(:params) { { 'id' => authority.id.to_s } }
    let(:body) { StringIO.new(authority.attributes.to_json) }

    context 'with a listener' do
      let(:listener) { FakeListener.new }

      before { Lark.config.event_stream.subscribe(listener) }

      it 'adds an update event to the stream' do
        expect { controller.update }
          .to change { listener.events.count }
          .by 1
      end
    end

    context 'with an unknown media type' do
      let(:headers) { { 'CONTENT_TYPE' => 'application/fake' } }

      it 'gives a 415 status' do
        expect(controller.create.first).to eq 415
      end
    end

    context 'with existing authority record' do
      let(:authority) do
        persister.save(resource: FactoryBot.create(:concept))
      end

      let(:body) do
        authority.pref_label = 'Label edited'
        StringIO.new(authority.attributes.to_json)
      end

      it 'gives a 204 no_content status' do
        expect(controller.update.first).to eq 204
      end
    end
  end

  describe '#show' do
    subject(:controller) { described_class.new(params: params) }

    let(:params)         { { 'id' => 'fake_id' } }

    it 'returns a rack response object' do
      expect(controller.show.first).to eq 404
    end
  end
end
