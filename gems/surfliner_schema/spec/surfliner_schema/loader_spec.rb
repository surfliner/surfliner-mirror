# frozen_string_literal: true

require "spec_helper"

describe SurflinerSchema::Loader do
  describe "search_paths" do
    describe "when Rails is defined and configured" do
      before do
        stub_const("Rails", Class.new)
        allow(Rails).to receive(:root) { "/the/rails/root" }
      end

      it "uses that path" do
        expect(SurflinerSchema::Loader.search_paths).to eq ["/the/rails/root"]
      end
    end

    describe "when Hyrax is defined and configured" do
      before do
        stub_const("Rails", Class.new)
        allow(Rails).to receive(:root) { "/the/rails/root" }
        stub_const("Hyrax::Engine", Class.new)
        allow(Hyrax::Engine).to receive(:root) { "/the/hyrax/root" }
      end

      it "uses that path" do
        expect(SurflinerSchema::Loader.search_paths).to eq [
          "/the/rails/root",
          "/the/hyrax/root"
        ]
      end
    end
  end

  describe "instance" do
    let(:reader_class) do
      Class.new(SurflinerSchema::Reader::Base) do
        def properties(availability:)
          {
            title: SurflinerSchema::Property.new(
              name: :title,
              display_label: "Title",
              available_on: [:generic_object, :collection, :Image],
              section: :my_metadata,
              indexing: [:searchable, :symbol],
              cardinality: :exactly_one
            ),
            date_uploaded: SurflinerSchema::Property.new(
              name: :date_uploaded,
              display_label: "Date Uploaded",
              available_on: [:generic_object, :Image],
              section: :my_metadata,
              grouping: :date,
              data_type: RDF::XSD.datetime
            ),
            date_modified: SurflinerSchema::Property.new(
              name: :date_modified,
              display_label: "Date Modified",
              available_on: [:generic_object, :Image],
              section: :my_metadata,
              grouping: :date,
              data_type: RDF::XSD.datetime
            ),
            unsupported_object: SurflinerSchema::Property.new(
              # for testing invalid ranges
              name: :unsupported_object,
              display_label: "Unsupported Object",
              available_on: [:unsupported_range_model],
              range: "example:unsupported_range"
            )
          }.filter { |_, property| property.available_on.include?(availability) }
        end

        def resource_classes
          {
            generic_object: SurflinerSchema::ResourceClass.new(
              name: :generic_object,
              display_label: "Generic Object",
              iri: "example:generic_object"
            ),
            collection: SurflinerSchema::ResourceClass.new(
              name: :collection,
              display_label: "Collection"
            ),
            unsupported_range_model: SurflinerSchema::ResourceClass.new(
              # for testing invalid ranges
              name: :unsupported_range_model,
              display_label: "Unsupported Range Model"
            ),
            Image: SurflinerSchema::ResourceClass.new(
              name: :Image,
              display_label: "Image"
            )
          }
        end

        def sections
          {
            my_metadata: SurflinerSchema::Section.new(
              name: :my_metadata,
              display_label: "My Metadata"
            )
          }
        end

        def groupings
          {
            date: SurflinerSchema::Grouping.new(
              name: :date,
              display_label: "Date"
            )
          }
        end
      end
    end
    let(:loader) { SurflinerSchema::Loader.for_readers([reader_class.new]) }

    describe "#struct_attributes_for" do
      let(:attributes) do
        loader.struct_attributes_for(:generic_object)
      end

      it "defines the attributes" do
        attributes.values.each do |attribute|
          expect(attribute).to be_a Dry::Types::Type
          expect(attribute.member).to be_a Dry::Types::Type
          expect(attribute.member.primitive).to eq RDF::Literal
        end
      end

      it "appropriately sets the datatypes" do
        # Attribute “values” are +Dry::Type+s; the +#[]+ syntax here is used to
        # construct new values. Resulting vaules should be +RDF::Literal+s with
        # the datatype defined in the schema.
        expect(attributes[:title].member["foo"]).to be_a RDF::Literal
        expect(attributes[:title].member["foo"].datatype).to eq RDF::XSD.string
        expect(attributes[:date_uploaded].member["1972-12-31T00:00:00Z"]).to be_a RDF::Literal
        expect(attributes[:date_uploaded].member["1972-12-31T00:00:00Z"].datatype).to eq RDF::XSD.datetime
      end

      it "raises an error with an unrecognized object property" do
        expect {
          loader.struct_attributes_for(:unsupported_range_model)
        }.to raise_error(SurflinerSchema::Reader::Error::UnknownRange)
      end
    end

    it "#form_definitions_for" do
      expect(loader.form_definitions_for(:collection).keys).to eq [:title]
    end

    it "#index_rules_for" do
      expect(loader.index_rules_for(schema: :generic_object).keys).to contain_exactly(
        :title_sim,
        :title_tsim
      )
      expect(loader.index_rules_for(schema: :generic_object)[:title_sim]).to eq :title
      expect(loader.index_rules_for(schema: :generic_object)[:title_tsim]).to eq :title
    end

    it "#availabilities" do
      expect(loader.availabilities).to contain_exactly :generic_object,
        :collection, :unsupported_range_model, :Image
    end

    describe "#class_division_for" do
      it "contains only the properties for the class" do
        div = loader.class_division_for(:generic_object)
        expect(div.properties).to eq loader.properties_for(:generic_object).values
      end

      it "correctly generates subdivisions" do
        div = loader.class_division_for(:generic_object)
        expect(div.to_a.map(&:name)).to eq [:my_metadata]
        section = div.first
        expect(section).to be_a SurflinerSchema::Division
        expect(section.kind).to eq :section
        expect(section.to_a.map(&:name)).to eq [:title, :date]
        grouping = section.drop(1).first
        expect(grouping).to be_a SurflinerSchema::Division
        expect(grouping.kind).to eq :grouping
        expect(grouping.to_a.map(&:name)).to eq [:date_uploaded, :date_modified]
      end

      it "filters properties when provided with a block" do
        div = loader.class_division_for(:generic_object) do |property|
          property.name == :title
        end
        expect(div.to_a.map(&:name)).to eq [:my_metadata]
        section = div.first
        expect(section).to be_a SurflinerSchema::Division
        expect(section.kind).to eq :section
        expect(section.to_a.size).to eq 1
        expect(section.to_a.map(&:name)).to eq [:title]
      end
    end

    describe "#resource_class_resolver" do
      after do
        if Object.const_defined?(:GenericObject)
          Object.send(:remove_const, :GenericObject)
        end
      end

      it "resolves a defined class" do
        klass = loader.resource_class_resolver.call(:GenericObject)
        expect(klass).to be_a Class
        expect(klass.availability).to eq :generic_object
      end

      it "defines a const" do
        klass = loader.resource_class_resolver.call(:GenericObject)
        expect(klass).to be GenericObject
      end

      it "resolves an iri to its corresponding class" do
        klass = loader.resource_class_resolver.call("example:generic_object")
        expect(klass).to be GenericObject
        expect(klass).to be_a Class
        expect(klass.availability).to eq :generic_object
      end

      it "throws an error for an undefined class" do
        expect { loader.resource_class_resolver.call(:NotInSchema) }.to raise_error NameError
      end

      it "defines the attributes" do
        klass = loader.resource_class_resolver.call(:GenericObject)
        expect { klass.new.title = "Etaoin" }.not_to raise_error
      end
    end
  end
end
