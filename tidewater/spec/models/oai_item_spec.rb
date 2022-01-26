require "rails_helper"

RSpec.describe OaiItem do
  describe "metadata_for" do
    it "replaces characters disallowed in XML with U+FFFD" do
      ["\x00", "\x12", "\uFFFE"].each do |badchar|
        subject.title = "foo#{badchar}bar"
        expect(
          subject.metadata_for("http://purl.org/dc/elements/1.1/title")
        ).to eq ["foo\uFFFDbar"]
      end
    end

    it "allows some special characters allowed in XML" do
      ["\x09", "\x0A", "\x20", "\x7F", "\u0085"].each do |goodchar|
        subject.title = "foo#{goodchar}bar"
        expect(
          subject.metadata_for("http://purl.org/dc/elements/1.1/title")
        ).to eq ["foo#{goodchar}bar"]
      end
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
      ).to eq ["Etaoin Shrdlu"]
    end

    it "returns fields with multiple values as an array of values" do
      subject.contributor = "Etaoin Shrdlu\uFFFFCmfwyp Vbgkqj"
      expect(
        subject.metadata_for("http://purl.org/dc/elements/1.1/contributor")
      ).to eq ["Etaoin Shrdlu", "Cmfwyp Vbgkqj"]
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
      subject.contributor = "Etaoin Shrdlu\uFFFFCmfwyp Vbgkqj"
      expect(dc_metadata.elements["oai_dc:dc/dc:contributor[1]"].text).to eq "Etaoin Shrdlu"
      expect(dc_metadata.elements["oai_dc:dc/dc:contributor[2]"].text).to eq "Cmfwyp Vbgkqj"
    end
  end
end
