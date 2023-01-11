# frozen_string_literal: true

require "spec_helper"

RSpec.describe SurflinerSchema do
  describe "::Schema()" do
    let(:model_class) do
      Class.new(Valkyrie::Resource)
    end

    let(:reader_class) do
      Class.new(SurflinerSchema::Reader::Base) do
        def properties(availability:)
          return unless availability == :my_availability
          {
            test_field: SurflinerSchema::Property.new(
              name: :test_field,
              display_label: "Test Field",
              available_on: [:my_availability]
            )
          }
        end
      end
    end
    let(:loader) { SurflinerSchema::Loader.for_readers([reader_class.new]) }

    it "builds a schema module" do
      expect(described_class.Schema(:my_availability, loader: loader))
        .to be_a described_class::Schema
    end

    it "adds attributes when included" do
      expect { model_class.include(described_class.Schema(:my_availability, loader: loader)) }
        .to change { model_class.attribute_names }
        .to include(:test_field)
    end
  end
end

RSpec.describe SurflinerSchema::Schema do
  subject(:schema_module) { SurflinerSchema::Schema.new(:my_availability, loader: double) }

  describe "#inspect" do
    it "has a readable value" do
      expect(schema_module.inspect)
        .to eq described_class.name + "(my_availability)"
    end
  end
end
