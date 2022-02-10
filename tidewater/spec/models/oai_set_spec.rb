# frozen_string_literal: true

require "rails_helper"

RSpec.describe OaiSet do
  subject(:oai_set) { described_class.new }

  describe "#source_iri" do
    let(:source_iri) { "any_oai_set_source_iri" }

    it "assigns source_iri" do
      expect { oai_set.source_iri = source_iri }
        .to change(oai_set, :source_iri)
        .from(be_nil)
        .to source_iri
    end
  end

  describe "#name" do
    let(:name) { "Test Collection" }

    it "assigns set_name" do
      expect { oai_set.name = name }
        .to change(oai_set, :name)
        .from(be_nil)
        .to name
    end
  end

  describe "#created_at" do
    let(:created_at) { Date.today.to_datetime }

    it "creates a timestamp" do
      expect { oai_set.created_at = created_at }
        .to change(oai_set, :created_at)
        .from(be_nil)
        .to created_at
    end
  end

  describe "#updated_at" do
    let(:updated_at) { Date.today.to_datetime }

    it "creates a timestamp" do
      expect { oai_set.updated_at = updated_at }
        .to change(oai_set, :updated_at)
        .from(be_nil)
        .to updated_at
    end
  end
end
