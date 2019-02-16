require 'spec_helper'
require_relative '../../lib/lark/record_parser'

RSpec.describe Lark::RecordParser do
  subject(:parser) { described_class.new }

  describe '.for' do
    it 'resolves json' do
      expect(described_class.for(content_type: 'application/json'))
        .to respond_to :parse
    end
  end

  describe '#parse' do
    it 'raises NotImplementedError' do
      expect { parser.parse(StringIO.new) }
        .to raise_error NotImplementedError
    end
  end
end
