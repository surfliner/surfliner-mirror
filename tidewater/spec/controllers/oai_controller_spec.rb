# frozen_string_literal: true

require "rails_helper"

RSpec.describe OaiController do
  describe "#index" do
    let!(:item) { OaiItem.create(title: "title", identifier: "ark://1234", creator: "surfliner") }
    it "returns individual metadata record for GetRecord verb" do
      get :index, params: {verb: "GetRecord", identifier: "oai:test:#{item.id}", metadata_prefix: "oai_dc"}
      expect(response).to have_http_status(200)
      expect(response.body).to include("surfliner")
    end

    it "routes to /oai" do
      expect(get: "/oai").to be_routable
    end
  end
end
