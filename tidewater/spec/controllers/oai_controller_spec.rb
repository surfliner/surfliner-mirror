# frozen_string_literal: true

require "rails_helper"

RSpec.describe OaiController do
  let!(:item) { OaiItem.create(title: "title", identifier: "ark://1234", creator: "surfliner", source_iri: "http://superskunk.example.com/1234") }
  let!(:item_2) { OaiItem.create(title: "title 2", identifier: "ark://4567", creator: "surfliner", source_iri: "http://superskunk.example.com/4567") }
  let!(:set_1) { OaiSet.create(name: "Computer Science", source_iri: "example:cs") }
  let!(:set_2) { OaiSet.create(name: "Mathematics", source_iri: "example:cs") }
  let!(:set_entry) { OaiSetEntry.create(oai_set_id: set_1.id, oai_item_id: item.id) }
  let!(:set_entry_2) { OaiSetEntry.create(oai_set_id: set_2.id, oai_item_id: item.id) }

  after do
    set_entry.delete
    set_entry_2.delete
    item.delete
    set_1.delete
    set_2.delete
  end

  describe "#index" do
    it "returns individual metadata record for GetRecord verb" do
      get :index, params: {verb: "GetRecord", identifier: "oai:test:#{item.id}", metadataPrefix: "oai_dc"}
      expect(response).to have_http_status(200)
      expect(response.body).to include("surfliner")
    end

    it "routes to /oai" do
      expect(get: "/oai").to be_routable
    end
  end

  describe "#ListSets" do
    it "returns the set structure of the repo for ListSets verb" do
      get :index, params: {verb: "ListSets"}
      expect(response).to have_http_status(200)
      expect(response.body).to include("Computer Science")
      expect(response.body).to include("Mathematics")
    end
  end

  describe "#ListIdentifiers" do
    it "returns all identifiers with set info" do
      get :index, params: {verb: "ListIdentifiers", metadataPrefix: "oai_dc"}

      expect(response).to have_http_status(200)
      expect(response.body).to include("oai:test:#{item.id}")
      expect(response.body).to include("oai:test:#{item_2.id}")
      expect(response.body).to include("<setSpec>#{set_1.id}</setSpec>")
      expect(response.body).to include("<setSpec>#{set_2.id}</setSpec>")
    end

    it "returns all identifiers in a set with set info" do
      get :index, params: {verb: "ListIdentifiers", metadataPrefix: "oai_dc", set: set_1.id}

      expect(response).to have_http_status(200)
      expect(response.body).to include("oai:test:#{item.id}")
      expect(response.body).to include("<setSpec>#{set_1.id}</setSpec>")

      # item_2 doesn't belong to set 1
      expect(response.body).to_not include("oai:test:#{item_2.id}")
    end

    it "returns all identifiers in a set for item belongs to multiple sets" do
      get :index, params: {verb: "ListIdentifiers", metadataPrefix: "oai_dc", set: set_1.id}

      # item belongs to both set_1 and set_2
      expect(response.body).to include("oai:test:#{item.id}")
      expect(response.body).to include("<setSpec>#{set_1.id}</setSpec>")
      expect(response.body).to include("<setSpec>#{set_2.id}</setSpec>")

      # item_2 doesn't belong to any set
      expect(response.body).to_not include("oai:test:#{item_2.id}")
    end
  end
end
