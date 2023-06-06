# frozen_string_literal: true

require "spec_helper"
require "rack/test"

RSpec.describe "GET /{id}" do
  include ::Rack::Test::Methods

  let(:app) { Lark.application }
  let(:id) { "a_fake_id" }
  let(:adapter) do
    Valkyrie::MetadataAdapter.find(Lark.config.index_adapter)
  end
  let(:persister) { adapter.persister }

  before { persister.wipe! }

  context "with no object" do
    it "gives a 404" do
      get "/#{id}"

      expect(last_response.status).to eq 404
    end
  end

  context "with an existing object" do
    let(:pref_label) { Label.new("Moomin") }
    let(:resource) do
      FactoryBot.create(:concept,
        id: id,
        pref_label: pref_label)
    end
    let(:response_expected) do
      {"pref_label" => ["Moomin"],
       "alternate_label" => [],
       "hidden_label" => [],
       "exact_match" => [],
       "close_match" => [],
       "note" => [],
       "scope_note" => [],
       "editorial_note" => [],
       "history_note" => [],
       "definition" => [],
       "identifier" => [],
       "id" => id}
    end

    before { persister.save(resource: resource) }

    after { persister.wipe! }

    it "gives a 200" do
      get "/#{id}"

      expect(last_response.status).to eq 200
    end

    it "gets the object matching the id" do
      get "/#{id}"

      expect(JSON.parse(last_response.body))
        .to eq response_expected
    end
  end

  context "with basic term search exact match" do
    let(:pref_label) { Label.new("authority 1") }
    let(:pref_label_alternate) { Label.new("alternate authority") }
    let(:alternate_label) { Label.new("alternate label") }

    before do
      FactoryBot.create(:concept,
        id: "a_fake_id1",
        pref_label: [pref_label])
      FactoryBot.create(:concept,
        id: "a_fake_id2",
        pref_label: [pref_label_alternate],
        alternate_label: [alternate_label])
    end

    after { persister.wipe! }

    context "with unsupported search term" do
      before { get "/search", any_term: "any term" }

      it "gives a 400 bad request" do
        expect(last_response.status).to eq 400
      end

      it "has header for CORS request" do
        expect(last_response.headers)
          .to include "Access-Control-Allow-Origin" => "*"
      end
    end

    context "with no terms matched pref_label" do
      before { get "/search", pref_label: "authority" }

      it "gives a 404 with term pref_label" do
        expect(last_response.status).to eq 404
      end

      it "has header for CORS request" do
        expect(last_response.headers)
          .to include "Access-Control-Allow-Origin" => "*"
      end
    end

    context "with no terms matched alternate_label" do
      before { get "/search", alternate_label: "authority" }

      it "gives a 404 with term alternate_label" do
        expect(last_response.status).to eq 404
      end

      it "has header for CORS request" do
        expect(last_response.headers)
          .to include "Access-Control-Allow-Origin" => "*"
      end
    end

    context "with term matched pref_label" do
      before { get "/search", pref_label: pref_label.to_s }

      it "gives a 200" do
        expect(last_response.status).to eq 200
      end

      it "contains the existing authority with pre_label matched" do
        expect(JSON.parse(last_response.body).first.symbolize_keys)
          .to include(pref_label: [pref_label.to_s], alternate_label: [])
      end

      it "has header for CORS request" do
        expect(last_response.headers)
          .to include "Access-Control-Allow-Origin" => "*"
      end
    end

    context "with term match alternate_label" do
      before { get "/search", alternate_label: alternate_label.to_s }

      it "gives a 200" do
        expect(last_response.status).to eq 200
      end

      it "contains the existing authority with alternate_label matched" do
        expect(JSON.parse(last_response.body).first.symbolize_keys)
          .to include(pref_label: [pref_label_alternate.to_s],
            alternate_label: [alternate_label.to_s])
      end

      it "has header for CORS request" do
        expect(last_response.headers)
          .to include "Access-Control-Allow-Origin" => "*"
      end
    end
  end
end
