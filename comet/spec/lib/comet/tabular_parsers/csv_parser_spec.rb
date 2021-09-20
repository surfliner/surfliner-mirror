# frozen_string_literal: true

require "spec_helper"
require_relative "../../../../lib/comet/tabular_parsers/csv_parser"

RSpec.describe Comet::TabularParsers::CSVParser do
  subject(:parser) { described_class.new }

  describe "#parse" do
    let(:csv_file) { Rails.root.join("spec", "fixtures", "batch.csv") }
    let(:data) do
      {"object unique id" => "obj#1", "level" => "Object", "file name" => "image.jpg", "title" => "Test Object"}
    end

    it "parses csv file" do
      expect(parser.parse(csv_file).first).to include(data)
    end
  end
end
