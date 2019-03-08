# frozen_string_literal: true

require 'spec_helper'
require_relative '../lib/lark'

RSpec.describe Lark do
  describe 'configuration' do
    let(:adapter) do
      Valkyrie::MetadataAdapter.find(described_class.config.index_adapter)
    end

    it 'has an index adapter' do
      expect(described_class.config.index_adapter).to be_a Symbol
    end

    it 'can change the index adapter' do
      old_adapter = described_class.config.index_adapter

      expect { described_class.config.index_adapter = :moomin }
        .to change { described_class.config.index_adapter }
        .to :moomin

      described_class.config.index_adapter = old_adapter
    end

    it 'has an event stream' do
      expect(described_class.config.event_stream).to respond_to :<<
    end

    it 'is a metadata adapter' do
      expect(adapter).to respond_to :persister
    end
  end
end
