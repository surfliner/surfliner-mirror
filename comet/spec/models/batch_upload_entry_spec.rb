# frozen_string_literal: true

require "rails_helper"

RSpec.describe BatchUploadEntry do
  subject(:entry) { described_class.new }

  describe "#entity_id" do
    let(:entity) { Sipity::Entity.new(id: 1) }

    it "assigns Sipity::Entity id" do
      expect { entry.entity_id = entity.id }
        .to change(entry, :entity_id)
        .from(be_nil)
        .to entity.id
    end
  end

  describe "#raw_metadata" do
    let(:raw_metadata) { {title: "Test"}.to_json }

    it "assigns raw_metadata" do
      expect { entry.raw_metadata = raw_metadata }
        .to change(entry, :raw_metadata)
        .from(be_nil)
        .to raw_metadata
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
end
