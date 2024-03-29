# frozen_string_literal: true

require "spec_helper"
require "valkyrie/specs/shared_specs"

RSpec.describe Event do
  subject(:event) { described_class.new }

  let(:resource_klass) { described_class }

  it_behaves_like "a Valkyrie::Resource"

  describe "#type" do
    it "accepts :create" do
      expect { event.type = :create }
        .to change(event, :type)
        .to :create
    end
  end

  describe "#data" do
    let(:data) { {authority_id: "moomin_id", type: :Concept} }

    it "defaults to an empty hash" do
      expect(event.data).to eq({})
    end

    it "accepts a new hash value" do
      expect { event.data = data }
        .to change(event, :data)
        .from(be_empty)
        .to data
    end
  end

  describe "#date_created" do
    let(:created_at) { Date.today.to_datetime }

    it "creates a timestamp" do
      expect { event.date_created = created_at }
        .to change(event, :date_created)
        .from(be_nil)
        .to created_at
    end
  end
end
