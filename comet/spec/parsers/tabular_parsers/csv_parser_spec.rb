# frozen_string_literal: true

require "rails_helper"

RSpec.describe TabularParsers::CSVParser do
  subject(:parser) { described_class.new }

  describe "#parse" do
    let(:csv_file) { Rails.root.join("spec", "fixtures", "batch.csv") }
    let(:data) do
      {"object unique id" => "obj#1", "level" => "Object", "file name" => "image.jpg", "title" => "Batch ingest object"}
    end

    it "parses csv file" do
      expect(parser.parse(csv_file).first).to include(data)
    end
  end
end
