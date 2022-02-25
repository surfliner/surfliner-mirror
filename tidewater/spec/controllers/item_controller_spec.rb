# frozen_string_literal: true

require "rails_helper"

RSpec.describe ItemController do
  describe "#index" do
    let(:source_iri) { "http://superskunk.example.com/1234" }
    let!(:item) { OaiItem.create(title: "title", identifier: "ark://1234", creator: "surfliner", source_iri: source_iri) }

    it "routes to /item" do
      expect(get: "/item").to be_routable
    end

    it "gives bad request when no source_iri param provided" do
      expect { get :index }.to raise_error(ActionController::BadRequest)
    end

    context "with valid source_iri" do
      let(:oai_params) { {verb: "GetRecord", identifier: "oai:#{ENV.fetch("OAI_NAMESPACE_IDENTIFIER")}:#{item.id}", metadataPrefix: "oai_dc"} }

      it "redirects to the OaiController with GetRecord verb" do
        get :index, params: {source_iri: source_iri}

        expect(response).to have_http_status(302)
        expect(response).to redirect_to %r{/oai}
        expect(Rack::Utils.parse_query(URI.parse(response.location).query).to_h)
          .to include(oai_params.stringify_keys)
      end
    end

    context "with invalid source_iri" do
      it "raises error ActiveRecord::RecordNotFound" do
        expect {
          get :index, params: {source_iri: "invalid-source-iri"}
        }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end
end
