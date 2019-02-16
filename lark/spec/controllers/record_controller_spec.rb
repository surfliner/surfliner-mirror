require 'spec_helper'
require_relative '../../config/environment'

RSpec.describe RecordController do
  let(:headers) { { 'CONTENT_TYPE' => 'application/json' } }

  let(:request) do
    double(Rack::Request,
           body: StringIO.new('{}'),
           env: headers)
  end

  describe '#create' do
    subject(:controller) { described_class.new(request: request) }

    it 'gives a 201 status' do
      expect(controller.create.first).to eq 201
    end
  end

  describe '#create' do
    subject(:controller) { described_class.new(request: request) }
    let(:event)          { FactoryBot.create(:create_event) }
    let(:listener)       { FakeListener.new }

    before { Lark.config.event_stream.subscribe(listener) }

    it 'adds an event to the stream' do
      expect { controller.create }
        .to change { listener.events.count }
        .by 1
    end
  end

  describe '#show' do
    subject(:controller) { described_class.new(params: params) }
    let(:params)         { { 'id' => 'a_fake_id' } }

    it 'returns a rack response object' do
      expect(subject.show.first).to eq 404
    end
  end
end
