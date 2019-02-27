# frozen_string_literal: true

require 'spec_helper'
require_relative '../../config/environment'

RSpec.describe RecordController do
  let(:headers) { { 'CONTENT_TYPE' => 'application/json' } }

  let(:request) do
    instance_double(Rack::Request,
                    body: StringIO.new('{}'),
                    env: headers)
  end

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
  end

  describe '#show' do
    subject(:controller) { described_class.new(params: params) }

    let(:params)         { { 'id' => 'a_fake_id' } }

    it 'returns a rack response object' do
      expect(controller.show.first).to eq 404
    end
  end
end
