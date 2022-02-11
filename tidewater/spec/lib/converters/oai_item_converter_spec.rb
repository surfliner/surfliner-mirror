require "rails_helper"

RSpec.describe Converters::OaiItemConverter do
  describe "convert JSON-LD to OaiItem record" do
    let(:source_id) { "example:cs/0112017" }
    let(:resource_uri) { "http://superskunk.example.com/#{source_id}" }
    let(:json_file) { Rails.root.join("spec", "fixtures", "mocked_metadata_response.json") }
    let(:json_data) { File.read(json_file) }
    let(:oai_item) { Converters::OaiItemConverter.from_json(resource_uri, json_data) }

    let(:title) { "Using Structural Metadata to Localize Experience of Digital Content\uFFFEen" }
    let(:creator) { "Dushay, Naomi" }
    let(:subject) { "Digital Libraries" }
    let(:description) { "With the increasing technical sophistication of both information consumers and providers, there is increasing demand for more meaningful experiences of digital information. We present a framework that separates digital object experience, or rendering, from digital object storage and manipulation, so the rendering can be tailored to particular communities of users.\uFFFEen\uFFFFComment: 23 pages including 2 appendices, 8 figures" }
    let(:date) { "2001-12-14" }
    let(:type) { "e-print" }
    let(:identifier) { "http://arXiv.org/abs/cs/0112017" }

    it "builds OaiItem record" do
      expect(oai_item["source_iri"]).to eq source_id
      expect(oai_item["title"]).to eq title
      expect(oai_item["creator"]).to eq creator
      expect(oai_item["subject"]).to eq subject
      expect(oai_item["description"]).to eq description
      expect(oai_item["date"]).to eq date
      expect(oai_item["type"]).to eq type
      expect(oai_item["identifier"]).to eq identifier
    end

    context "with inconsistent resourceUrl and @id" do
      let(:resource_uri) { "http://superskunk.example.com/1234" }

      it "raises ArgumentError" do
        expect { Converters::OaiItemConverter.from_json(resource_uri, json_data) }
          .to raise_error(ArgumentError, "Inconsistent @id example:cs/0112017 and resource URL http://superskunk.example.com/1234!")
      end
    end
  end
end
