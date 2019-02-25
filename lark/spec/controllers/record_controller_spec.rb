require 'spec_helper'
require_relative '../../config/environment'

RSpec.describe RecordController do
  subject(:controller) { described_class.new(params: params) }
  let(:params)         { { 'id' => 'a_fake_id' } }

  describe '#create' do
    subject(:controller) { described_class.new(request: request) }
    let(:event)          { FactoryBot.create(:create_event) }
    let(:listener)       { FakeListener.new }
    let(:request)        { double(body: StringIO.new('{}')) }

    before { Lark.config.event_stream.subscribe(listener) }

    it 'adds an event to the stream' do
      expect { controller.create }
        .to change { listener.events.count }
        .by 1
    end
  end

  describe '#show' do
    it 'returns a rack response object' do
      expect(subject.show.first).to eq 404
    end
  end
end
