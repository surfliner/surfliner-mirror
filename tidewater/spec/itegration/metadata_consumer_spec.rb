# frozen_string_literal: true

require "rails_helper"
require "net/http"

RSpec.describe "consume Comet JSON-LD metadata" do
  let(:mocked_server) { ENV.fetch("SUPERSKUNK_MOCK_SERVER_URL", "http://mmock:8083") }

  let(:source_id) { "example:cs/0112017" }
  let(:resource_uri) { "#{mocked_server}/#{source_id}" }
  let(:title) { "Using Structural Metadata to Localize Experience of Digital Content\uFFFEen" }
  let(:creator) { "Dushay, Naomi" }
  let(:subject) { "Digital Libraries" }
  let(:description) { "With the increasing technical sophistication of both information consumers and providers, there is increasing demand for more meaningful experiences of digital information. We present a framework that separates digital object experience, or rendering, from digital object storage and manipulation, so the rendering can be tailored to particular communities of users.\uFFFEen\uFFFFComment: 23 pages including 2 appendices, 8 figures" }
  let(:date) { "2001-12-14" }
  let(:type) { "e-print" }
  let(:identifier) { "http://arXiv.org/abs/cs/0112017" }

  describe "OaiItem#create" do
    let(:mocked_response) { mock_response(resource_uri) }

    let(:mocked_data) { mocked_response.body }
    let(:oai_item) { Converters::OaiItemConverter.from_json(resource_uri, mocked_data) }

    before do
      Persisters::SuperskunkPersister.delete(source_iri: source_id)
    end

    it "returns 200 response and JSON-LD content" do
      expect(mocked_response.code).to eq "200"
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
      expect(Persisters::SuperskunkPersister.create_or_update(record: oai_item)).to be > 0

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

  describe "OaiSet#create" do
    let(:mocked_response) { mock_response(resource_uri) }
    let(:mocked_data) { mocked_response.body }
    let(:oai_sets) { Converters::OaiSetConverter.from_json(mocked_data) }

    before do
      oai_sets.each do |attr|
        Persisters::SuperskunkSetPersister.delete(source_iri: attr["source_iri"])
      end
    end

    it "persist OaiSet example:cs" do
      expect(Persisters::SuperskunkSetPersister.create_or_update(record: oai_sets[0])).to be > 0
      Persisters::SuperskunkSetPersister.find_by_source_iri(oai_sets[0]["source_iri"]) do |oai_set|
        expect(oai_set.source_iri).to eq "example:cs"
        expect(oai_set.name).to eq "Computer Science"
      end

      expect(Persisters::SuperskunkSetPersister.create_or_update(record: oai_sets[1])).to be > 0
      Persisters::SuperskunkSetPersister.find_by_source_iri(oai_sets[1]["source_iri"]) do |oai_set|
        expect(oai_set.source_iri).to eq "example:math"
        expect(oai_set.name).to eq "Mathematics"
      end
    end
  end

  describe "OaiSetEntry#create" do
    let(:mocked_response) { mock_response(resource_uri) }
    let(:mocked_data) { mocked_response.body }
    let(:oai_item) { Converters::OaiItemConverter.from_json(resource_uri, mocked_data) }
    let(:oai_set) { Converters::OaiSetConverter.from_json(mocked_data).first }
    let(:set_source_iri) { oai_set["source_iri"] }

    before do
      Persisters::SuperskunkSetEntryPersister.delete_entries(set_source_iri: set_source_iri)

      Persisters::SuperskunkPersister.create_or_update(record: oai_item)
      Persisters::SuperskunkSetPersister.create_or_update(record: oai_set)
    end

    after do
      Persisters::SuperskunkSetEntryPersister.delete_entries(set_source_iri: set_source_iri)
      Persisters::SuperskunkSetPersister.delete(source_iri: set_source_iri)
      Persisters::SuperskunkPersister.delete(source_iri: source_id)
    end

    it "persist OaiSet example:cs" do
      expect(Persisters::SuperskunkSetEntryPersister.create(set_source_iri: set_source_iri, item_source_iri: source_id))
        .to be > 0

      expect(Persisters::SuperskunkSetEntryPersister.find_by_set_source_iri(set_source_iri: set_source_iri).length)
        .to eq 1
    end
  end

  describe "OaiSetEntry#delete" do
    let(:mocked_response) { mock_response(resource_uri) }
    let(:mocked_data) { mocked_response.body }
    let(:oai_item) { Converters::OaiItemConverter.from_json(resource_uri, mocked_data) }
    let(:oai_set) { Converters::OaiSetConverter.from_json(mocked_data).first }
    let(:set_source_iri) { oai_set["source_iri"] }

    before do
      Persisters::SuperskunkSetEntryPersister.delete_entries(set_source_iri: set_source_iri)

      Persisters::SuperskunkPersister.create_or_update(record: oai_item)
      Persisters::SuperskunkSetPersister.create_or_update(record: oai_set)
      Persisters::SuperskunkSetEntryPersister.create(set_source_iri: set_source_iri, item_source_iri: source_id)
    end

    after do
      Persisters::SuperskunkSetEntryPersister.delete_entries(set_source_iri: set_source_iri)
      Persisters::SuperskunkSetPersister.delete(source_iri: set_source_iri)
      Persisters::SuperskunkPersister.delete(source_iri: source_id)
    end

    it "persist OaiSet example:cs" do
      expect(Persisters::SuperskunkSetEntryPersister.entry_exists?(set_source_iri: set_source_iri, item_source_iri: source_id))
        .to be true

      Persisters::SuperskunkSetEntryPersister.delete_entry(set_source_iri: set_source_iri, item_source_iri: source_id)

      expect(Persisters::SuperskunkSetEntryPersister.entry_exists?(set_source_iri: set_source_iri, item_source_iri: source_id))
        .to be false
    end
  end

  describe "OaiSetEntry#find_by_item_source_iri" do
    let(:mocked_response) { mock_response(resource_uri) }
    let(:mocked_data) { mocked_response.body }
    let(:oai_item) { Converters::OaiItemConverter.from_json(resource_uri, mocked_data) }
    let(:oai_set) { Converters::OaiSetConverter.from_json(mocked_data).first }
    let(:set_source_iri) { oai_set["source_iri"] }

    before do
      Persisters::SuperskunkSetEntryPersister.delete_entries(set_source_iri: set_source_iri)

      Persisters::SuperskunkPersister.create_or_update(record: oai_item)
      Persisters::SuperskunkSetPersister.create_or_update(record: oai_set)
      Persisters::SuperskunkSetEntryPersister.create(set_source_iri: set_source_iri, item_source_iri: source_id)
    end

    after do
      Persisters::SuperskunkSetEntryPersister.delete_entries(set_source_iri: set_source_iri)
      Persisters::SuperskunkSetPersister.delete(source_iri: set_source_iri)
      Persisters::SuperskunkPersister.delete(source_iri: source_id)
    end

    it "found the SetEntry by OaiItem source_iri" do
      expect(Persisters::SuperskunkSetEntryPersister.entry_exists?(set_source_iri: set_source_iri, item_source_iri: source_id))
        .to be true

      expect(Persisters::SuperskunkSetEntryPersister.find_sets_source_iri_by_item(item_source_iri: source_id))
        .to include(set_source_iri)
    end
  end
end
