# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FindByStringProperty do
  subject(:query) { described_class.new(query_service: query_service) }

  let(:adapter) { Valkyrie::MetadataAdapter.find(Lark.config.index_adapter) }
  let(:query_service) { adapter.query_service }
  let(:authority) { FactoryBot.create(:concept, pref_label: ['PrefLabel']) }

  before { adapter.persister.wipe! }

  describe '#find_by_string_property' do
    it 'can find the authority with value of a property' do
      result = query.find_by_string_property(property: :pref_label,
                                             value: authority.pref_label.first)

      expect(result.map { |au| au.id.id.to_s }).to include authority.id.to_s
    end

    context 'when no match' do
      it 'returns no results' do
        result = query.find_by_string_property(property: :pref_label,
                                               value: 'Any label')
        expect(result.to_a).to be_empty
      end
    end
  end
end
