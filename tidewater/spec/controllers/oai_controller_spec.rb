# frozen_string_literal: true

require "rails_helper"

RSpec.describe OaiController do
  describe "#index" do
    let!(:item) { OaiItem.create(title: "title", identifier: "ark://1234", creator: "surfliner", source_iri: "http://superskunk.example.com/1234") }

    it "returns individual metadata record for GetRecord verb" do
      get :index, params: {verb: "GetRecord", identifier: "oai:test:#{item.id}", metadataPrefix: "oai_dc"}
      expect(response).to have_http_status(200)
      expect(response.body).to include("surfliner")
    end

    it "routes to /oai" do
      expect(get: "/oai").to be_routable
    end
  end

  describe "#listSets" do
    let!(:set_1) { OaiSet.create(name: "Computer Science", source_iri: "example:cs") }
    let!(:set_2) { OaiSet.create(name: "Mathematics", source_iri: "example:cs") }

    it "returns the set structure of the repo for ListSets verb" do
      get :index, params: {verb: "ListSets"}
      expect(response).to have_http_status(200)
      expect(response.body).to include("Computer Science")
      expect(response.body).to include("Mathematics")
    end
  end
end
