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
    let(:loader_class) { SurflinerSchema::Loader }
    let(:reader_class) do
      Class.new(SurflinerSchema::Reader) do
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
    let(:loader) { loader_class.for_readers([reader_class.new(valkyrie_resource_class: loader_class.valkyrie_resource_class_for(:""))]) }

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

      describe "returning a class from valkyrie_resource_class_for" do
        let(:base_class) { Class.new(Valkyrie::Resource) }
        let(:loader_class) {
          result = Class.new(SurflinerSchema::Loader) do
            def self.valkyrie_resource_class_for(_)
              @base_class
            end
          end
          result.instance_variable_set(:@base_class, base_class)
          result
        }

        it "subclasses the class" do
          klass = loader.resource_class_resolver.call(:GenericObject)
          expect(klass.superclass).to eq base_class
        end
      end

      describe "returning a proc from valkyrie_resource_class_for" do
        let(:class_cache) do
          # Just to make the classes retrievable in tests…
          {}
        end
        let(:base_class_proc) {
          ->(a) do
            class_cache[a.name] ||= Class.new(Valkyrie::Resource) do
              # Some simple behaviours for testing…
              @__test_was_created_by = a.name
              class << self
                attr_reader :__test_was_created_by
              end
            end
          end
        }
        let(:loader_class) {
          result = Class.new(SurflinerSchema::Loader) do
            def self.valkyrie_resource_class_for(_)
              @base_class_proc
            end
          end
          result.instance_variable_set(:@base_class_proc, base_class_proc)
          result
        }

        it "subclasses the class returned by the proc" do
          klass = loader.resource_class_resolver.call(:GenericObject)
          expect(klass.superclass).to eq class_cache[:generic_object]
        end

        it "provides the proc with the class description" do
          klass = loader.resource_class_resolver.call(:GenericObject)
          expect(klass.superclass.__test_was_created_by).to eq :generic_object
        end
      end
    end
  end
end
