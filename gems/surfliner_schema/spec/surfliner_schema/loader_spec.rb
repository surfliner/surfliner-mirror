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
              grouping: :date
            ),
            date_modified: SurflinerSchema::Property.new(
              name: :date_modified,
              display_label: "Date Modified",
              available_on: [:generic_object, :Image],
              section: :my_metadata,
              grouping: :date
            )
          }.filter { |_, property| property.available_on.include?(availability) }
        end

        def resource_classes
          {
            generic_object: SurflinerSchema::ResourceClass.new(
              name: :generic_object,
              display_label: "Generic Object"
            ),
            collection: SurflinerSchema::ResourceClass.new(
              name: :collection,
              display_label: "Collection"
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

    it "#attributes_for" do
      # is there a better way of checking this?
      typestr = Valkyrie::Types::Set.of(
        Valkyrie::Types.Constructor(RDF::Literal)
      ).to_s
      expect(loader.struct_attributes_for(:generic_object).transform_values(&:to_s)).to include(
        **{
          title: typestr,
          date_modified: typestr,
          date_uploaded: typestr
        }.transform_values(&:to_s)
      )
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
      expect(loader.availabilities).to eq [:generic_object, :collection, :Image]
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
