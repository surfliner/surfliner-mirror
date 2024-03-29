# frozen_string_literal: true

require "spec_helper"

describe SurflinerSchema::Reader::SimpleSchema do
  describe "instance" do
    let(:loader_class) {
      Class.new(SurflinerSchema::Loader) do
        attr_reader :readers

        def self.config_location
          "spec/fixtures"
        end
      end
    }
    let(:loader) { loader_class.new([:simple_schema]) }
    let(:reader) { loader.readers[0] }

    it "has an empty profile" do
      expect(reader.profile.responsibility).to be_nil
      expect(reader.profile.responsibility_statement).to be_nil
      expect(reader.profile.date_modified).to be_nil
      expect(reader.profile.type).to be_nil
      expect(reader.profile.version).to be_nil
      expect(reader.profile.additional_metadata).to eq({})
    end

    it "derives display labels" do
      properties = reader.properties(availability: :generic_object)
      expect(properties[:date_uploaded].display_label).to eq "Date Uploaded"
    end

    it "#form_definitions" do
      form_definitions = reader.form_definitions(availability: :generic_object)
      expect(form_definitions.keys).to eq [:title]
      title_definition = form_definitions[:title]
      expect(title_definition.required?).to be true
      expect(title_definition.multiple?).to be false
    end

    it "#indices" do
      indices = reader.indices(availability: :generic_object)
      expect(indices.keys).to contain_exactly(
        :title_sim,
        :title_tsim,
        :title_tesim
      )
      expect(indices[:title_sim].name).to eq :title
      expect(indices[:title_tsim].name).to eq :title
      expect(indices[:title_tesim].name).to eq :title
    end

    it "#resource_classes" do
      resource_classes = reader.resource_classes
      expect(resource_classes.keys).to eq [:generic_object]
      class_definition = resource_classes[:generic_object]
      expect(class_definition.name).to eq :generic_object
      expect(class_definition.display_label).to eq "Generic Object"
    end
  end
end
