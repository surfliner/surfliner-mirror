# frozen_string_literal: true

require "spec_helper"

RSpec.describe SurflinerSchema do
  describe "::FormFields()" do
    let(:form_class) {
      form_class = Class.new(Valkyrie::ChangeSet)
      allow(form_class).to receive(:property).and_call_original
      form_class
    }

    let(:reader_class) do
      Class.new(SurflinerSchema::Reader) do
        def resource_classes
          {
            my_availability: SurflinerSchema::ResourceClass.new(
              name: :my_availability,
              display_label: "My Availability"
            )
          }
        end

        def properties(availability:)
          {
            primary_field: SurflinerSchema::Property.new(
              name: :primary_field,
              display_label: "Primary Field",
              available_on: :my_availability,
              cardinality_class: :exactly_one
            ),
            secondary_field: SurflinerSchema::Property.new(
              name: :secondary_field,
              display_label: "Secondary Field",
              available_on: :my_availability,
              cardinality_class: :zero_or_more
            )
          }
        end

        def form_definitions(availability:)
          properties(availability: availability).transform_values do |prop|
            SurflinerSchema::FormDefinition.new(
              property: prop,
              primary: prop.name == :primary_field
            )
          end
        end
      end
    end
    let(:reader) { reader_class.new }
    let(:model_class) { reader.resolve(:my_availability) }

    it "builds a form fields module" do
      expect(described_class.FormFields(model_class))
        .to be_a described_class::FormFields
    end

    it "adds a :form_definition method when included" do
      expect { form_class.include(described_class.FormFields(model_class)) }
        .to change { form_class.public_methods }
        .to include :form_definition
    end

    describe "when included" do
      before do
        form_class.include(described_class.FormFields(model_class))
      end

      it "defines properties" do
        expect(form_class).to have_received(:property).twice
        expect(form_class).to have_received(:property)
          .with(:primary_field, hash_including(:default))
        expect(form_class).to have_received(:property)
          .with(:secondary_field, hash_including(:default))
      end

      describe "the added :form_definition class method" do
        it "maps properties to form definitions" do
          expect(form_class.form_definition(:primary_field)).to be_a SurflinerSchema::FormDefinition
          expect(form_class.form_definition(:primary_field).primary?).to be true
          expect(form_class.form_definition(:secondary_field)).to be_a SurflinerSchema::FormDefinition
          expect(form_class.form_definition(:secondary_field).primary?).to be false
          expect(form_class.form_definition(:nonexistent_field)).to be_nil
        end
      end

      describe "the added :primary_division class method" do
        it "returns a SurflinerSchema::Division" do
          expect(form_class.primary_division).to be_a SurflinerSchema::Division
        end

        it "includes only primary properties" do
          expect(form_class.primary_division.to_a.map(&:name)).to eq [:primary_field]
        end
      end

      describe "the added :secondary_division class method" do
        it "returns a SurflinerSchema::Division" do
          expect(form_class.secondary_division).to be_a SurflinerSchema::Division
        end

        it "includes only nonprimary properties" do
          expect(form_class.secondary_division.to_a.map(&:name)).to eq [:secondary_field]
        end
      end

      describe "the added :schema_contract class method" do
        it "returns a SurflinerSchema::Contract" do
          expect(form_class.schema_contract.superclass).to be SurflinerSchema::Contract
        end

        it "returns the same SurflinerSchema::Contract every time" do
          c1 = form_class.schema_contract
          c2 = form_class.schema_contract
          expect(c1).to be c2
        end
      end

      # These aren’t great tests but I’m not sure we can do much better—we’re
      # essentially testing against Reform internal behaviour here.
      describe "the deserialize! override" do
        it "does not set @result when coercion succeeds" do
          form = form_class.new(model_class.new)
          form.send(:deserialize!, {primary_field: "foo", secondary_field: "bar"})
          expect(form.instance_variable_get(:@result).to_results).to be_empty
        end

        it "sets @result when validation fails" do
          form = form_class.new(model_class.new)
          form.send(:deserialize!, {primary_field: [], secondary_field: []})
          results = form.instance_variable_get(:@result).to_results
          expect(results).not_to be_empty
          expect(results.first.failure?).to be true
        end

        it "casts schema values" do
          form = form_class.new(model_class.new)
          params = form.send(:deserialize!, {primary_field: "my field"})
          expect(params[:primary_field]).to contain_exactly RDF::Literal.new("my field")
          expect(params[:secondary_field]).to eq []
        end

        it "preserves non‐schema values" do
          form = form_class.new(model_class.new)
          params = form.send(:deserialize!, {title: "Etaoin Shrdlu", primary_field: "my field"})
          expect(params[:title]).to eq "Etaoin Shrdlu"
        end

        it "re·uses existing values when new ones are not provided" do
          form = form_class.new(model_class.new({primary_field: ["my field"]}))
          params = form.send(:deserialize!, {})
          expect(form.instance_variable_get(:@result).to_results).to be_empty
          expect(params[:primary_field]).to contain_exactly RDF::Literal.new("my field")
        end
      end
    end
  end
end

RSpec.describe SurflinerSchema::FormFields do
  subject(:fields_module) {
    model_class = double
    reader = double
    allow(model_class).to receive(:availability).and_return(:my_availability)
    allow(model_class).to receive(:reader).and_return reader
    allow(reader).to receive(:form_definitions).with(any_args) { {} }
    SurflinerSchema::FormFields.new(model_class)
  }

  describe "#inspect" do
    it "has a readable value" do
      expect(fields_module.inspect)
        .to eq described_class.name + "(my_availability)"
    end
  end
end
