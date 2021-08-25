# frozen_string_literal: true

require "spec_helper"

RSpec.describe FindByEventDataProperty do
  subject(:query) { described_class.new(query_service: query_service) }

  let(:adapter) { Valkyrie::MetadataAdapter.find(Lark.config.index_adapter) }
  let(:event_adapter) do
    Valkyrie::MetadataAdapter.find(Lark.config.event_adapter)
  end
  let(:query_service) { event_adapter.query_service }
  let(:id) { "a_fake_id" }
  let(:data) { {authority_id: id, pref_label: "moomin"} }
  let(:event) { Event.new type: :create, data: data }

  before do
    adapter.persister.wipe!
    event_adapter.persister.wipe!
    Lark::EventStream.instance << event
  end

  after do
    adapter.persister.wipe!
    event_adapter.persister.wipe!
  end

  describe "#sql_find_by_event_data_property" do
    it "can find the authority with value of a property" do
      result = query.find_by_event_data_property(property: :authority_id,
        value: id)

      expect(result.map { |evn| evn.data[:authority_id] }).to include id
    end

    it "has pref_label property" do
      result = query.find_by_event_data_property(property: :pref_label,
        value: "moomin")

      expect(result.map { |evn| evn.data[:pref_label] }).to include "moomin"
    end
  end
end
