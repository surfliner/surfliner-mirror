# frozen_string_literal: true

require "spec_helper"

RSpec.describe Queries::FindByEventProperty do
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

  describe "#find_by_string_property" do
    it "returns search results" do
      result = query.find_by_event_property(property: :type,
        value: :create)

      expect(result.size).to eq 1
    end

    it "can find the event with value of a property" do
      result = query.find_by_event_property(property: :type,
        value: :create)

      expect(result.first.type).to eq "create"
    end
  end
end
