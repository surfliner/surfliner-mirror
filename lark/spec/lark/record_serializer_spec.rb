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

  describe '.serialize' do
    subject(:json) do
      described_class.for(content_type: 'application/json')
                     .serialize(record: record)
    end

    let(:record) { Lark::FakeResource.new(id: 'a_fake_id', label: 'Label') }

    it 'return json string' do
      expect(json).to eq JSON.dump(label: ['Label'], note: [], id: 'a_fake_id')
    end
  end
end
