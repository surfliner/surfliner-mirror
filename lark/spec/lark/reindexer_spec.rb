# frozen_string_literal: true

require "spec_helper"

RSpec.describe Lark::Reindexer do
  subject(:reindexer) { described_class.new }

  let(:index_adapter) { Valkyrie::MetadataAdapter.find(Lark.config.index_adapter) }
  let(:query_service) { index_adapter.query_service }
  let(:event_adapter) { Valkyrie::MetadataAdapter.find(Lark.config.event_adapter) }

  before do
    index_adapter.persister.wipe!
    event_adapter.persister.wipe!
  end

  describe "#reindex" do
    subject(:attrs) do
      event_adapter.persister.save(resource: event_create)
      event_adapter.persister.save(resource: event_change)
      event_adapter.persister.save(resource: event_update)
      reindexer.reindex_record id: id

      query_service.find_by(id: id).attributes
    end

    let(:id) { "a_fake_id" }
    let(:authority) { Concept.new(id: id, pref_label: "moomin") }
    let(:data) { {authority_id: id, changes: {pref_label: "moomin"}} }
    let(:event_create) { Event.new type: :create, data: {authority_id: id, changes: {}} }
    let(:event_change) { Event.new type: :change_properties, data: data }

    context "with missing authority record" do
      let(:data_change) { {authority_id: id, changes: {pref_label: "moomin edited"}} }
      let(:event_update) { Event.new type: :change_properties, data: data_change }

      before { index_adapter.persister.save(resource: authority) }

      it "reindex record" do
        expect(attrs[:pref_label]).to contain_exactly Label.new("moomin edited")
      end
    end

    context "with existing authority record" do
      let(:data_change) do
        {authority_id: id,
         changes: {pref_label: "moomin edited", alternate_label: "Alternate label"}}
      end
      let(:event_update) { Event.new type: :change_properties, data: data_change }

      before { index_adapter.persister.save(resource: authority) }

      it "contains :pref_label" do
        expect(attrs[:pref_label]).to contain_exactly Label.new("moomin edited")
      end

      it "contains :alternate_label" do
        expect(attrs[:alternate_label]).to contain_exactly Label.new("Alternate label")
      end
    end
  end

  describe "#reindex_all" do
    let(:id1) { "a_fake_id_1" }
    let(:authority1) { Concept.new(id: id1, pref_label: "moomin") }
    let(:data1) { {authority_id: id1, changes: {pref_label: "moomin"}} }
    let(:event_create1) { Event.new type: :create, data: {authority_id: id1, changes: {}} }
    let(:event_changes1) { Event.new type: :change_properties, data: data1 }

    let(:data_change1) do
      {authority_id: id1, changes: {pref_label: "moomin updated 1"}}
    end
    let(:event_update1) do
      Event.new type: :change_properties, data: data_change1
    end

    let(:id2) { "a_fake_id_2" }
    let(:authority2) { Concept.new(id: id2, pref_label: "moomin") }
    let(:data2) { {authority_id: id2, changes: {pref_label: "moomin"}} }
    let(:event_create2) { Event.new type: :create, data: {authority_id: id2, changes: {}} }
    let(:event_changes2) { Event.new type: :change_properties, data: data2 }

    let(:data_change2) do
      {authority_id: id2, changes: {pref_label: "moomin updated 2"}}
    end
    let(:event_update2) do
      Event.new type: :change_properties, data: data_change2
    end

    before do
      index_adapter.persister.save(resource: authority1)
      index_adapter.persister.save(resource: authority2)

      event_adapter.persister.save(resource: event_create1)
      event_adapter.persister.save(resource: event_changes1)
      event_adapter.persister.save(resource: event_update1)

      event_adapter.persister.save(resource: event_create2)
      event_adapter.persister.save(resource: event_changes2)
      event_adapter.persister.save(resource: event_update2)

      reindexer.reindex_all
    end

    it "re-index the record with changes" do
      expect(query_service.find_by(id: id1).attributes[:pref_label])
        .to contain_exactly Label.new("moomin updated 1")
    end

    it "re-index other records with changes" do
      expect(query_service.find_by(id: id2).attributes[:pref_label])
        .to contain_exactly Label.new("moomin updated 2")
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
