# frozen_string_literal: true

require "spec_helper"

describe SurflinerSchema::Resource do
  let(:reader_class) do
    Class.new(SurflinerSchema::Reader) do
      def properties(availability:)
        {
          value: SurflinerSchema::Property.new(
            name: :value,
            display_label: "Value",
            property_uri: RDF::RDFV.value,
            available_on: [:my_resource]
          ),
          pref_label: SurflinerSchema::Property.new(
            name: :pref_label,
            display_label: "Preferred Label",
            property_uri: "http://www.w3.org/2004/02/skos/core#prefLabel",
            available_on: [:my_resource, :only_labelled]
          )
        }.filter { |_, property| property.available_on.include?(availability) }
      end

      def resource_classes
        {
          my_resource: SurflinerSchema::ResourceClass.new(
            name: :my_resource,
            display_label: "My Resource"
          ),
          only_labelled: SurflinerSchema::ResourceClass.new(
            name: :only_labelled,
            display_label: "Only label no value"
          )
        }
      end
    end
  end
  let(:reader) { reader_class.new(valkyrie_resource_class: SurflinerSchema::Resource) }

  describe "when a resource has an rdf:value" do
    let(:resource_class) { reader.resolve(:my_resource) }

    it ".value_property_name" do
      expect(resource_class.value_property_name).to eq :value
    end

    it "casts from a value" do
      expect(resource_class.new("my value").value).to contain_exactly RDF::Literal("my value")
    end

    it "builds from a hash" do
      resource = resource_class.new({value: "my value", pref_label: "Mine"})
      expect(resource.value).to contain_exactly RDF::Literal("my value")
      expect(resource.pref_label).to contain_exactly RDF::Literal("Mine")
    end

    it "has terms" do
      resource = resource_class.new({value: "my value"})
      expect(resource.terms?).to be true
    end

    it "returns its terms" do
      resource = resource_class.new({value: "my value"})
      expect(resource.terms).to contain_exactly RDF::Literal("my value")
    end
  end

  describe "when a resource has no rdf:value" do
    let(:resource_class) { reader.resolve(:only_labelled) }

    it ".value_property_name" do
      expect(resource_class.value_property_name).to be_nil
    end

    it "cannot cast from a value" do
      expect { resource_class.new("my value") }.to raise_error Dry::Struct::Error
    end

    it "builds from a hash" do
      resource = resource_class.new({pref_label: "Mine"})
      expect(resource.pref_label).to contain_exactly RDF::Literal("Mine")
    end

    it "does not terms" do
      resource = resource_class.new
      expect(resource.terms?).to be false
    end

    it "cannot return its terms" do
      resource = resource_class.new
      expect { resource.terms }.to raise_error TypeError
    end
  end
end
