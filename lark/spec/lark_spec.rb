require 'spec_helper'
require_relative '../lib/lark'

RSpec.describe Lark do
  describe 'configuration' do
    before { @old_adapter = Lark.config.index_adapter }
    after  { Lark.config.index_adapter = @old_adapter }

    it 'has an index adapter' do
      expect(Lark.config.index_adapter).to be_a Symbol
    end

    it 'can change the index adapter' do
      expect { Lark.config.index_adapter = :moomin }
        .to change { Lark.config.index_adapter }
        .to :moomin
    end

    it 'has an event stream' do
      expect(Lark.config.event_stream).to respond_to :<<
      expect(Lark.config.event_stream).to respond_to :subscribe
    end
  end
end
