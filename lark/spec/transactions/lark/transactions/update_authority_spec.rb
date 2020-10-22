# frozen_string_literal: true

require 'spec_helper'
require_relative '../../../../config/environment'

RSpec.describe Lark::Transactions::UpdateAuthority do
  subject(:transaction) do
    described_class.new(event_stream: event_stream, adapter: adapter)
  end

  let(:adapter) do
    Valkyrie::MetadataAdapter.find(Lark.config.index_adapter)
  end

  let(:event_stream) { [] }
  let(:authority) do
    adapter.persister.save(resource: FactoryBot.create(:concept))
  end

  describe '#call' do
    let(:attributes) { { pref_label: label } }
    let(:id) { authority.id }
    let(:label) { ['Label edited'] }

    it 'adds :update_attributes to the event stream' do
      expect { transaction.call(id: id, attributes: attributes) }
        .to change { event_stream }
        .to contain_exactly have_attributes(type: :change_properties)
    end

    it 'returns an updated authority' do
      expect(transaction.call(id: id, attributes: attributes).value!)
        .to have_attributes(id: authority.id, pref_label: ['Label edited'])
    end
  end
end
