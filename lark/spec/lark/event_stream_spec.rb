# frozen_string_literal: true

require "spec_helper"

RSpec.describe Lark::EventStream do
  subject(:stream) { described_class.instance }

  let(:data) do
    {authority_id: "a-fade-id",
     pref_label: "moomin", alternate_label: "alternate label"}
  end
  let(:event) { Event.new type: :create, data: data }

  describe "#<<" do
    it "returns the event with id" do
      expect((stream << event).id).not_to be nil
    end

    it "returns the event with data" do
      expect((stream << event).data.to_h).to include data
    end

    context "with subscribers" do
      let(:listener) { FakeListener.new }

      before { stream.subscribe(listener) }

      it "publishes the event to subscribers" do
        expect { stream << event }
          .to change { listener.events.count }
          .by 1
      end
    end
  end
end
