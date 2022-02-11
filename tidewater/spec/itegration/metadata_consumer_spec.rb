# frozen_string_literal: true

require "rails_helper"
require "rest-client"

RSpec.describe "consume Comet JSON-LD metadata" do
  let(:mocked_json_file) { Rails.root.join("spec", "fixtures", "mocked_metadata_response.json") }
  let(:headers) { {"Accept" => "application/json", "HTTP_ACCEPT" => "application/ld+json;profile=tag:surfliner.github.io,2022:api/oai_dc"} }

  let(:source_id) { "example:cs/0112017" }
  let(:resource_uri) { "http://superskunk.example.com/#{source_id}" }
  let(:title) { "Using Structural Metadata to Localize Experience of Digital Content\uFFFEen" }
  let(:creator) { "Dushay, Naomi" }
  let(:subject) { "Digital Libraries" }
  let(:description) { "With the increasing technical sophistication of both information consumers and providers, there is increasing demand for more meaningful experiences of digital information. We present a framework that separates digital object experience, or rendering, from digital object storage and manipulation, so the rendering can be tailored to particular communities of users.\uFFFEen\uFFFFComment: 23 pages including 2 appendices, 8 figures" }
  let(:date) { "2001-12-14" }
  let(:type) { "e-print" }
  let(:identifier) { "http://arXiv.org/abs/cs/0112017" }

  describe "#create" do
    let(:mocked_response) { RestClient.get(resource_uri, headers) }
    let(:mocked_data) { mocked_response.body }
    let(:oai_item) { Converters::OaiItemConverter.from_json(resource_uri, mocked_data) }

    before do
      stub_request(:get, "http://superskunk.example.com:80/#{source_id}")
        .with(headers: headers)
        .to_return(body: File.new(mocked_json_file), status: 200)

      Persisters::SuperskunkPersister.delete(source_iri: source_id)
    end

    it "returns 200 response and JSON-LD content" do
      expect(mocked_response.code).to eq 200
      expect(JSON.parse(mocked_data).to_h).to include("identifier" => "http://arXiv.org/abs/cs/0112017")
    end

    it "build OaiItem" do
      expect(oai_item["source_iri"]).to eq source_id
      expect(oai_item["title"]).to eq title
      expect(oai_item["creator"]).to eq creator
      expect(oai_item["subject"]).to eq subject
      expect(oai_item["description"]).to eq description
      expect(oai_item["date"]).to eq date
      expect(oai_item["type"]).to eq type
      expect(oai_item["identifier"]).to eq identifier
    end

    it "persist OaiItem" do
      expect(Persisters::SuperskunkPersister.create_or_update(record: oai_item.with_indifferent_access)).to be > 0

      Persisters::SuperskunkPersister.find_by_source_iri(source_id) do |oai_item|
        expect(oai_item.source_iri).to eq source_id
        expect(oai_item.title).to eq title
        expect(oai_item.creator).to eq creator
        expect(oai_item.subject).to eq subject
        expect(oai_item.description).to eq description
        expect(oai_item.date).to eq date
        expect(oai_item.type).to eq type
        expect(oai_item.identifier).to eq identifier
      end
    end
  end
end
