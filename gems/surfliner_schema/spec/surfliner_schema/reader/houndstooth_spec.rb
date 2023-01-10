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
  let(:loader) { loader_class.new([:houndstooth]) }
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

  it "establishes correct mappings" do
    mappings = reader.properties(availability: :GenericWork)[:title].mappings_for("tag:surfliner.gitlab.io,2022:api/oai_dc")
    expect(mappings).to contain_exactly("http://purl.org/dc/terms/title")
  end

  it "allows specializations" do
    unspecialized_mappings = reader.properties(
      availability: :GenericWork
    )[:title].mappings_for("example:my_mapping")
    expect(unspecialized_mappings).to contain_exactly

    specialized_mappings = reader.properties(
      availability: :Friend
    )[:title].mappings_for("example:my_mapping")
    expect(specialized_mappings).to contain_exactly("http://xmlns.com/foaf/0.1/name")
  end

  it "derives (only) missing display labels" do
    properties = reader.properties(availability: :GenericWork)
    expect(properties[:date_uploaded].display_label).to eq "Date Uploaded"
    expect(properties[:date_modified].display_label).to eq "Last modified"
  end

  describe "#form_definitions" do
    it "includes some fields" do
      expect(reader.form_definitions(availability: :GenericWork)).not_to be_empty
    end
  end

  describe "#resource_classes" do
    it "contains the expected classes" do
      resource_classes = reader.resource_classes
      expect(resource_classes.keys).to eq [:Collection, :GenericWork, :Image]
    end

    it "generates classes with the correct name" do
      expect(reader.resource_classes[:Collection].name).to eq :Collection
      expect(reader.resource_classes[:GenericWork].name).to eq :GenericWork
      expect(reader.resource_classes[:Image].name).to eq :Image
    end

    it "generates classes with the correct display label" do
      expect(reader.resource_classes[:Collection].display_label).to eq "Collection"
      expect(reader.resource_classes[:GenericWork].display_label).to eq "Generic Work"
      expect(reader.resource_classes[:Image].display_label).to eq "Image"
    end
  end

  describe "#sections" do
    it "contains the expected sections" do
      expect(reader.sections.keys).to eq [:my_metadata]
    end
  end

  describe "#groupings" do
    it "contains the expected groupings" do
      expect(reader.groupings.keys).to eq [:date]
    end
  end
end
