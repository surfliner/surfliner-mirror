# frozen_string_literal: true

require "rails_helper"

RSpec.describe OaiSetEntry do
  subject(:entry) { described_class.new }

  describe "#oai_set_id" do
    it "assigns oai_set_id" do
      expect { entry.oai_set_id = 1 }
        .to change(entry, :oai_set_id)
        .from(be_nil)
        .to 1
    end
  end

  describe "#oai_item_id" do
    let(:oai_item_id) { 2 }

    it "assigns oai_item_id" do
      expect { entry.oai_item_id = oai_item_id }
        .to change(entry, :oai_item_id)
        .from(be_nil)
        .to 2
    end
  end

  describe "#created_at" do
    let(:created_at) { Date.today.to_datetime }

    it "creates a timestamp" do
      expect { entry.created_at = created_at }
        .to change(entry, :created_at)
        .from(be_nil)
        .to created_at
    end
  end

  describe "#updated_at" do
    let(:updated_at) { Date.today.to_datetime }

    it "creates a timestamp" do
      expect { entry.updated_at = updated_at }
        .to change(entry, :updated_at)
        .from(be_nil)
        .to updated_at
    end
  end
end
