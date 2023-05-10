# frozen_string_literal: true

require "rails_helper"

RSpec.describe Bulkrax::CometCsvParser do
  subject(:parser) { described_class.new(importer) }
  let(:importer) { nil }

  describe "#entry_class" do
    it "is the custom CsvParser" do
      expect(parser.entry_class).to eq Bulkrax::CometCsvEntry
    end
  end

  describe "#work_entry_class" do
    it "is the custom CsvParser" do
      expect(parser.work_entry_class).to eq Bulkrax::CometCsvEntry
    end
  end
end
