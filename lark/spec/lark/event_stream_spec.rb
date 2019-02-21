require 'spec_helper'
require_relative '../../lib/lark/event_stream'

RSpec.describe Lark::EventStream do
  subject(:stream) { described_class.instance }
  let(:event)      { :fake_event }

  describe '#<<' do
    it 'returns the event' do
      expect(stream << event).to eq event
    end
  end
end
