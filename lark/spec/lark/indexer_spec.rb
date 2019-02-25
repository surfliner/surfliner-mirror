require 'spec_helper'
require_relative '../../lib/lark/indexer'

RSpec.describe Lark::Indexer do
  subject(:indexer) { described_class.new }

  describe '#index' do
    it 'returns a concept' do
      expect(indexer.index(data: {})).to be_a Concept
    end
  end
end
