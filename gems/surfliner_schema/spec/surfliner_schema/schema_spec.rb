# frozen_string_literal: true

require "spec_helper"

RSpec.describe SurflinerSchema do
  describe "::Schema()" do
    let(:model_class) do
      Class.new(Valkyrie::Resource)
    end

    let(:fake_loader) do
      Class.new do
        def struct_attributes_for(availability)
          availability == :my_availability ? {test_field: Valkyrie::Types::String} : {}
        end
      end
    end
    let(:loader) { fake_loader.new }

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
