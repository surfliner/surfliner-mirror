# frozen_string_literal: true

require "spec_helper"

describe SurflinerSchema::Reader::Houndstooth do
  let(:loader_class) {
    Class.new(SurflinerSchema::Loader) do
      attr_reader :readers

      def self.config_location
        "spec/fixtures"
      end
    end
  }
  let(:loader) { loader_class.new([:core_metadata]) }
  let(:reader) { loader.readers[0] }

  it "correctly determines availability" do
    expect(reader.names(availability: :GenericWork)).to contain_exactly(
      :title,
      :date_uploaded,
      :date_modified
    )
    expect(reader.names(availability: :Collection)).not_to include(:date_uploaded)
    expect(reader.names(availability: :Collection)).not_to include(:date_modified)
  end

  describe "#form_options" do
    it "includes some fields" do
      expect(reader.form_options(availability: :GenericWork)).not_to be_empty
    end
  end
end
