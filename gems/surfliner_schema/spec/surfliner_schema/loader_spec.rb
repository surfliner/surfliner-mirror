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
    let(:loader_class) {
      Class.new(SurflinerSchema::Loader) do
        def self.config_location
          "spec/fixtures"
        end

        def self.default_schemas
          [:core_schema]
        end
      end
    }
    let(:loader) { loader_class.new }

    it "#attributes_for" do
      # is there a better way of checking this?
      typestr = Valkyrie::Types::Set.of(
        Valkyrie::Types.Constructor(RDF::Literal)
      ).to_s
      expect(loader.struct_attributes_for(:generic_object).transform_values(&:to_s)).to include(
        **{
          title: typestr,
          date_modified: typestr,
          date_uploaded: typestr,
          depositor: typestr
        }.transform_values(&:to_s)
      )
    end

    it "#form_definitions_for" do
      expect(loader.form_definitions_for(:generic_object).keys).to eq [:title]
    end

    it "#index_rules_for" do
      expect(loader.index_rules_for(schema: :generic_object).keys).to contain_exactly(
        :title_sim,
        :title_tsim,
        :title_tesim
      )
      expect(loader.index_rules_for(schema: :generic_object)[:title_sim]).to eq :title
      expect(loader.index_rules_for(schema: :generic_object)[:title_tsim]).to eq :title
      expect(loader.index_rules_for(schema: :generic_object)[:title_tesim]).to eq :title
    end

    it "#resource_classes" do
      expect(loader.resource_classes.keys).to eq [:generic_object]
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
        expect(klass.resource_class).to be_a SurflinerSchema::ResourceClass
        expect(klass.resource_class.name).to eq :generic_object
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
