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
    let(:form) { form_class.new }

    let(:loader) do
      loader = instance_double("SurflinerSchema::Loader")
      allow(loader).to receive(:form_definitions_for).and_return({})
      allow(loader).to receive(:form_definitions_for).with(:my_availability) do
        {
          primary_field: SurflinerSchema::FormDefinition.new(
            property: instance_double(
              "SurflinerSchema::Property",
              cardinality_class: :exactly_one
            ),
            primary: true
          ),
          secondary_field: SurflinerSchema::FormDefinition.new(
            property: instance_double(
              "SurflinerSchema::Property",
              cardinality_class: :zero_or_more
            )
          )
        }
      end
      loader
    end

    it "builds a form fields module" do
      expect(described_class.FormFields(:my_availability, loader: loader))
        .to be_a described_class::FormFields
    end

    it "adds a :form_definition method when included" do
      expect { form_class.include(described_class.FormFields(:my_availability, loader: loader)) }
        .to change { form.public_methods }
        .to include :form_definition
    end

    describe "when included" do
      before do
        form_class.include(described_class.FormFields(:my_availability, loader: loader))
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

      it "the added :form_definition method maps properties to form definitions" do
        expect(form.form_definition(:primary_field)).to be_a SurflinerSchema::FormDefinition
        expect(form.form_definition(:primary_field).primary?).to be true
        expect(form.form_definition(:secondary_field)).to be_a SurflinerSchema::FormDefinition
        expect(form.form_definition(:secondary_field).primary?).to be false
        expect(form.form_definition(:nonexistent_field)).to be_nil
      end
    end
  end
end

RSpec.describe SurflinerSchema::FormFields do
  subject(:fields_module) {
    loader = double
    allow(loader).to receive(:form_definitions_for).with(any_args) { {} }
    SurflinerSchema::FormFields.new(:my_availability, loader: loader)
  }

  describe "#inspect" do
    it "has a readable value" do
      expect(fields_module.inspect)
        .to eq described_class.name + "(my_availability)"
    end
  end
end
