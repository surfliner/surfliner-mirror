require "rails_helper"

REPLACEMENT = "\uFFFD"
LANG_DELIMITER = "\uFFFE"
TERM_DELIMITER = "\uFFFF"

RSpec.describe OaiItem do
  describe "metadata_for" do
    it "replaces characters disallowed in XML with U+FFFD" do
      ["\x00", "\x12"].each do |badchar|
        subject.title = "foo#{badchar}bar"
        expect(
          subject.metadata_for("http://purl.org/dc/elements/1.1/title")
        ).to eq [{value: "foo\uFFFDbar"}]
      end
    end

    it "allows some special characters allowed in XML" do
      ["\x09", "\x0A", "\x20", "\x7F", "\u0085"].each do |goodchar|
        subject.title = "foo#{goodchar}bar"
        expect(
          subject.metadata_for("http://purl.org/dc/elements/1.1/title")
        ).to eq [{value: "foo#{goodchar}bar"}]
      end
    end

    it "parses out the language" do
      subject.title = "#{LANG_DELIMITER}no#{LANG_DELIMITER}good#{LANG_DELIMITER}en"
      expect(
        subject.metadata_for("http://purl.org/dc/elements/1.1/title")
      ).to eq [{
        value: "#{REPLACEMENT}no#{REPLACEMENT}good",
        language: "en"
      }]
    end

    it "returns fields with no value as an empty array" do
      expect(
        subject.metadata_for("http://purl.org/dc/elements/1.1/contributor")
      ).to eq []
    end

    it "returns fields with one value as an array with one element" do
      subject.contributor = "Etaoin Shrdlu"
      expect(
        subject.metadata_for("http://purl.org/dc/elements/1.1/contributor")
      ).to eq [{value: "Etaoin Shrdlu"}]
    end

    it "returns fields with multiple values as an array of values" do
      subject.contributor = "Etaoin Shrdlu#{TERM_DELIMITER}Cmfwyp Vbgkqj"
      expect(
        subject.metadata_for("http://purl.org/dc/elements/1.1/contributor")
      ).to eq [
        {value: "Etaoin Shrdlu"},
        {value: "Cmfwyp Vbgkqj"}
      ]
    end
  end

  describe "to_oai_dc" do
    let(:dc_metadata) do
      REXML::Document.new(subject.to_oai_dc)
    end

    it "creates an <oai:dc> element with the correct attributes" do
      expect(dc_metadata.root.expanded_name).to eq "oai_dc:dc"
      expect(dc_metadata.root.attributes["xmlns:oai_dc"]).to eq "http://www.openarchives.org/OAI/2.0/oai_dc/"
      expect(dc_metadata.root.attributes["xmlns:dc"]).to eq "http://purl.org/dc/elements/1.1/"
      expect(dc_metadata.root.attributes["xmlns:xsi"]).to eq "http://www.w3.org/2001/XMLSchema-instance"
      expect(dc_metadata.root.attributes["xsi:schemaLocation"]).to eq(
        "http://www.openarchives.org/OAI/2.0/oai_dc/ "\
        "http://www.openarchives.org/OAI/2.0/oai_dc.xsd"
      )
    end

    it "creates Dublin Core children" do
      subject.title = "Foo Bar"
      subject.contributor = "Etaoin Shrdlu"
      expect(dc_metadata.elements["oai_dc:dc/dc:title"].text).to eq "Foo Bar"
      expect(dc_metadata.elements["oai_dc:dc/dc:contributor"].text).to eq "Etaoin Shrdlu"
    end

    it "creates multiple children for terms with multiple values" do
      subject.contributor = "Etaoin Shrdlu#{TERM_DELIMITER}Cmfwyp Vbgkqj"
      expect(dc_metadata.elements["oai_dc:dc/dc:contributor[1]"].text).to eq "Etaoin Shrdlu"
      expect(dc_metadata.elements["oai_dc:dc/dc:contributor[2]"].text).to eq "Cmfwyp Vbgkqj"
    end

    it "sets @xml:lang when a language is provided" do
      subject.contributor = "Etaoin Shrdlu#{LANG_DELIMITER}#{TERM_DELIMITER}Cmfwyp Vbgkqj#{LANG_DELIMITER}zxx"
      expect(dc_metadata.elements["oai_dc:dc/dc:contributor[1]"].text).to eq "Etaoin Shrdlu"
      expect(dc_metadata.elements["oai_dc:dc/dc:contributor[1]"].attributes["xml:lang"]).to eq ""
      expect(dc_metadata.elements["oai_dc:dc/dc:contributor[2]"].text).to eq "Cmfwyp Vbgkqj"
      expect(dc_metadata.elements["oai_dc:dc/dc:contributor[2]"].attributes["xml:lang"]).to eq "zxx"
    end

    it "does not set @xml:lang when no language is provided" do
      subject.contributor = "Etaoin Shrdlu"
      expect(dc_metadata.elements["oai_dc:dc/dc:contributor[1]"].attributes["xml:lang"]).to be nil
    end

    it "does not add source_iri" do
      subject.source_iri = "http://superskunk.example.com/1234"
      subject.identifier = "ark://1234"
      expect(dc_metadata.root.find_first_recursive { |e| e.text == subject.source_iri }).to be nil
      expect(dc_metadata.elements["oai_dc:dc/dc:identifier"].text).to eq subject.identifier
    end
  end

  describe "convert JSON-LD to OaiItem record" do
    let(:resource_uri) { "http://superskunk.example.com/1234" }
    let(:json_file) { Rails.root.join("spec", "fixtures", "mocked_metadata_response.json") }
    let(:json_data) { File.open(json_file).read }
    let(:oai_item) { OaiItem.from_json(resource_uri, json_data) }

    let(:resource_uri) { "http://superskunk.example.com/1234" }
    let(:title) { "Using Structural Metadata to Localize Experience of Digital Content\uFFFEen" }
    let(:creator) { "Dushay, Naomi" }
    let(:subject) { "Digital Libraries" }
    let(:description) { "With the increasing technical sophistication of both information consumers and providers, there is increasing demand for more meaningful experiences of digital information. We present a framework that separates digital object experience, or rendering, from digital object storage and manipulation, so the rendering can be tailored to particular communities of users.\uFFFEen\uFFFFComment: 23 pages including 2 appendices, 8 figures" }
    let(:date) { "2001-12-14" }
    let(:type) { "e-print" }
    let(:identifier) { "http://arXiv.org/abs/cs/0112017" }

    it "builds OaiItem record" do
      expect(oai_item).to be_a OaiItem

      expect(oai_item.source_iri).to eq resource_uri
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
