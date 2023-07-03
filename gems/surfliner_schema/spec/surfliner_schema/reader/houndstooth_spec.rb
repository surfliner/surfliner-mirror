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

  it "has the correct profile" do
    expect(reader.profile.responsibility).to eq "https://gitlab.com/surfliner"
    expect(reader.profile.responsibility_statement).to eq "the Project Surfliner team"
    expect(reader.profile.date_modified).to eq Date.new(2023, 5, 22)
    expect(reader.profile.type).to eq :testdata
    expect(reader.profile.version).to eq "testing"
    expect(reader.profile.additional_metadata).to include my_custom_field: "My completely arbitrary custom value"
  end

  it "correctly determines availability" do
    expect(reader.names(availability: :GenericWork)).to contain_exactly(
      :title,
      :date_uploaded,
      :date_modified,
      :controlled,
      :range
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

  it "correctly processes controlled values when specified" do
    properties = reader.properties(availability: :GenericWork)
    controlled_values = properties[:controlled].controlled_values
    expect(controlled_values).not_to be_nil
    expect(controlled_values.sources).to contain_exactly(
      "https://example.example/values",
      "http://my.example/vocab"
    )
    expect(controlled_values.values.keys).to contain_exactly(:named, :_1)
    expect(controlled_values.values[:named].name).to eq :named
    expect(controlled_values.values[:named].display_label).to eq "Named"
    expect(controlled_values.values[:named].iri).to eq "about:surfliner_schema/controlled_values/controlled/named"
    expect(controlled_values.values[:_1].name).to eq :_1
    expect(controlled_values.values[:_1].display_label).to eq "Unnamed with IRI"
    expect(controlled_values.values[:_1].iri).to eq "example:unnamed"
  end

  it "gives nil when no controlled values are specified" do
    properties = reader.properties(availability: :GenericWork)
    expect(properties[:date_modified].controlled_values).to be_nil
  end

  describe "#form_definitions" do
    it "includes some fields" do
      expect(reader.form_definitions(availability: :GenericWork)).not_to be_empty
    end
  end

  describe "#resource_classes" do
    it "contains the expected classes" do
      resource_classes = reader.resource_classes
      expect(resource_classes.keys).to eq [:Collection, :GenericWork, :Image, :Nested]
    end

    it "generates classes with the correct name" do
      expect(reader.resource_classes[:Collection].name).to eq :Collection
      expect(reader.resource_classes[:GenericWork].name).to eq :GenericWork
      expect(reader.resource_classes[:Image].name).to eq :Image
      expect(reader.resource_classes[:Nested].name).to eq :Nested
    end

    it "generates classes with the correct display label" do
      expect(reader.resource_classes[:Collection].display_label).to eq "Collection"
      expect(reader.resource_classes[:GenericWork].display_label).to eq "Generic Work"
      expect(reader.resource_classes[:Image].display_label).to eq "Image"
      expect(reader.resource_classes[:Nested].display_label).to eq "Nested"
    end

    it "identifies whether classes are nested" do
      expect(reader.resource_classes[:Collection].nested).to be false
      expect(reader.resource_classes[:GenericWork].nested).to be false
      expect(reader.resource_classes[:Image].nested).to be false
      expect(reader.resource_classes[:Nested].nested).to be true
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
