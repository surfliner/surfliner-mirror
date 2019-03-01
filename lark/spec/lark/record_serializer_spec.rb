# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lark::RecordSerializer do
  subject(:serializer) { described_class.new }

  describe '.for' do
    it 'resolves json' do
      expect(described_class.for(content_type: 'application/json'))
        .to respond_to :serialize
    end

    it 'raises UnsupportedMediaType for unknown formats' do
      expect { described_class.for(content_type: 'application/fake') }
        .to raise_error Lark::UnsupportedMediaType
    end
  end
end
