require "rails_helper"

RSpec.describe Converters::OaiSetConverter do
  describe "convert JSON-LD to OaiSet record" do
    let(:json_file) { Rails.root.join("spec", "fixtures", "mocked_metadata_response.json") }
    let(:json_data) { File.read(json_file) }

    let(:oai_sets_expected) {
      [{source_iri: "example:cs", name: "Computer Science"}, {source_iri: "example:math", name: "Mathematics"}].as_json
    }

    it "builds OaiSet records" do
      expect(Converters::OaiSetConverter.from_json(json_data)).to eq oai_sets_expected
    end
  end
end
