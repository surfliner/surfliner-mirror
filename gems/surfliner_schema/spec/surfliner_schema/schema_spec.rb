# frozen_string_literal: true

require "spec_helper"

RSpec.describe SurflinerSchema do
  describe "::Schema()" do
    let(:model_class) do
      Class.new(Valkyrie::Resource)
    end

    let(:fake_loader) do
      Class.new do
        def struct_attributes_for(schema_name)
          schema_name == :test_schema ? {test_field: Valkyrie::Types::String} : {}
        end
      end
    end

    it "builds a schema module" do
      expect(described_class.Schema(:test_schema, loader: fake_loader.new))
        .to be_a described_class::Schema
    end

    it "adds attributes when included" do
      expect { model_class.include(described_class.Schema(:test_schema, loader: fake_loader.new)) }
        .to change { model_class.attribute_names }
        .to include(:test_field)
    end
  end
end

RSpec.describe SurflinerSchema::Schema do
  subject(:schema_module) { SurflinerSchema::Schema.new(:my_schema_name, loader: double) }

  describe "#inspect" do
    it "has a readable value" do
      expect(schema_module.inspect)
        .to eq described_class.name + "(my_schema_name)"
    end
  end
end
