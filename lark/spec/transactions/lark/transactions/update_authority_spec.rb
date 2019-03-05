# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lark::Transactions::UpdateAuthority do
  include ActionDispatch::TestProcess

  subject(:update) do
    described_class.new(event_stream: event_stream)
                   .call(id: id, attributes: { pref_label: label },
                         adapter: adapter)
  end

  let(:adapter) do
    Valkyrie::MetadataAdapter.find(Lark.config.index_adapter)
  end
  let(:persister) { adapter.persister }

  let(:event_stream) { [] }
  let(:authority) do
    persister.save(resource: Concept.new(pref_label: 'PrefLabel'))
  end

  describe '#call' do
    let(:id) { authority.id }
    let(:label) { ['Label edited'] }

    it 'adds :update to the event stream' do
      expect { update }
        .to change { event_stream }
        .to contain_exactly have_attributes(type: :update)
    end

    it 'returns an updated authority' do
      expect(update.value!)
        .to have_attributes(id: authority.id, pref_label: ['Label edited'])
    end
  end
end
