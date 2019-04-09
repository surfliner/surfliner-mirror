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

    before do
      class Resource < Valkyrie::Resource
        attribute :label, Valkyrie::Types::Set
        attribute :note, Valkyrie::Types::Set

        def primary_terms
          %i[label note]
        end
      end
    end

    after do
      Object.send(:remove_const, :Resource)
    end

    let(:record) { Resource.new(id: 'a_fake_id', label: 'Label') }

    it 'return json string' do
      expect(json).to eq JSON.dump(label: ['Label'], note: [], id: 'a_fake_id')
    end
  end
end
