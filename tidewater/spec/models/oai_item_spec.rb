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
end
