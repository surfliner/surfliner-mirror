# frozen_string_literal: true

require_relative "../../app/services/batch_uploads_validator"
require_relative "../../app/parsers/tabular_parsers/csv_parser"

RSpec.describe BatchUploadsValidator do
  subject(:validator) { described_class.validator_for(schema) }
  let(:schema) { "batch_uploads_validation" }

  describe ".validator_for" do
    it "response to :invalid_headers" do
      expect(described_class.validator_for("batch_uploads_validation"))
        .to respond_to :invalid_headers
    end
  end

  describe "#validate" do
    subject(:parser) { TabularParsers::CSVParser.new }
    let(:csv_file) { Rails.root.join("spec", "fixtures", "batch.csv") }
    let(:csv_file_invalid) { Rails.root.join("spec", "fixtures", "batch_invalid.csv") }

    it "returns no invalidate headers" do
      expect(validator.invalid_headers(parser.parse(csv_file).first)).to be_empty
    end

    it "gives invalidate headers" do
      expect(validator.invalid_headers(parser.parse(csv_file_invalid).first))
        .to include("invalid header")
    end
  end
end
