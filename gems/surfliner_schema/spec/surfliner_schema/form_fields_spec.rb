# frozen_string_literal: true

require "spec_helper"

RSpec.describe SurflinerSchema do
  describe "::FormFields()" do
    let(:form_class) {
      form_class = Class.new
      allow(form_class).to receive(:property)
      allow(form_class).to receive(:validates)
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

      it "defines validations for required fields" do
        expect(form_class).to have_received(:validates).once
        expect(form_class).to have_received(:validates)
          .with(:primary_field, presence: true)
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
