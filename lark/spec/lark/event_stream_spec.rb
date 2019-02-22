require 'spec_helper'
require_relative '../../lib/lark/event_stream'

RSpec.describe Lark::EventStream do
  subject(:stream) { described_class.instance }
  let(:event)      { double(type: :Create, data: {}) }

  describe '#<<' do
    it 'returns the event' do
      expect(stream << event).to eq event
    end

    context 'with subscribers' do
      let(:listener) { FakeListener.new }

      before { stream.subscribe(listener) }

      it 'publishes the event to subscribers' do
        expect { stream << event }
          .to change { listener.events.count }
          .by 1
      end
    end
  end
end
