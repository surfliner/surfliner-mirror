# frozen_string_literal: true

require 'spec_helper'
require_relative '../../lib/lark/reindexer'

RSpec.describe Lark::Reindexer do
  subject(:reindexer) { described_class.new }

  let(:adapter) do
    Valkyrie::MetadataAdapter.find(Lark.config.index_adapter)
  end
  let(:query_service) { adapter.query_service }
  let(:event_adapter) do
    Valkyrie::MetadataAdapter.find(Lark.config.event_adapter)
  end

  describe '#reindex(id:)' do
    let(:id) { 'a_fade_id' }
    let(:authority) { Concept.new(id: id, pref_label: 'moomin') }
    let(:data) { { authority_id: id, changes: { pref_label: 'moomin' } } }
    let(:event_create) { Event.new type: :create, data: { authority_id: id, changes: {} } }
    let(:event_change) { Event.new type: :change_properties, data: data }

    let(:data_change) { { authority_id: id, changes: { pref_label: 'moomin edited' } } }
    let(:event_update) do
      Event.new type: :change_properties, data: data_change
    end

    before do
      adapter.persister.save(resource: authority)
      event_adapter.persister.save(resource: event_create)
      event_adapter.persister.save(resource: event_change)
      event_adapter.persister.save(resource: event_update)

      reindexer.reindex_record id: id
    end

    after do
      adapter.persister.wipe!
      event_adapter.persister.wipe!
    end

    it 'reindex the record' do
      expect(query_service.find_by(id: id).attributes)
        .to include(pref_label: ['moomin edited'])
    end
  end

  describe '#reindex_all' do
    let(:id1) { 'a_fade_id_1' }
    let(:authority1) { Concept.new(id: id1, pref_label: 'moomin') }
    let(:data1) { { authority_id: id1, changes: { pref_label: 'moomin' } } }
    let(:event_create1) { Event.new type: :create, data: { authority_id: id1, changes: {} } }
    let(:event_changes1) { Event.new type: :change_properties, data: data1 }

    let(:data_change1) do
      { authority_id: id1, changes: { pref_label: 'moomin updated 1' } }
    end
    let(:event_update1) do
      Event.new type: :change_properties, data: data_change1
    end

    let(:id2) { 'a_fade_id_2' }
    let(:authority2) { Concept.new(id: id2, pref_label: 'moomin') }
    let(:data2) { { authority_id: id2, changes: { pref_label: 'moomin' } } }
    let(:event_create2) { Event.new type: :create, data: { authority_id: id2, changes: {} } }
    let(:event_changes2) { Event.new type: :change_properties, data: data2 }

    let(:data_change2) do
      { authority_id: id2, changes: { pref_label: 'moomin updated 2' } }
    end
    let(:event_update2) do
      Event.new type: :change_properties, data: data_change2
    end

    before do
      adapter.persister.save(resource: authority1)
      adapter.persister.save(resource: authority2)

      event_adapter.persister.save(resource: event_create1)
      event_adapter.persister.save(resource: event_changes1)
      event_adapter.persister.save(resource: event_update1)

      event_adapter.persister.save(resource: event_create2)
      event_adapter.persister.save(resource: event_changes2)
      event_adapter.persister.save(resource: event_update2)

      reindexer.reindex_all
    end

    after do
      adapter.persister.wipe!
      event_adapter.persister.wipe!
    end

    it 're-index the record with changes' do
      expect(query_service.find_by(id: id1).attributes)
        .to include(pref_label: ['moomin updated 1'])
    end

    it 're-index other records with changes' do
      expect(query_service.find_by(id: id2).attributes)
        .to include(pref_label: ['moomin updated 2'])
    end
  end
end
