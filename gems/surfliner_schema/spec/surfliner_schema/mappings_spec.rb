# frozen_string_literal: true

require "spec_helper"

RSpec.describe SurflinerSchema do
  describe "::Mappings()" do
    let(:model_class) do
      Class.new(Valkyrie::Resource) do
        attribute :test_field
      end
    end
    let(:resource) { model_class.new(test_field: "etaoin") }

    let(:fake_loader) do
      Class.new do
        def property_mappings_for(availability, schema_iri:)
          return {} unless availability == :my_availability
          schema_iri == "example:mapping" ? {
            test_field: Set.new(["example:mapping#test_property"])
          } : {}
        end
      end
    end
    let(:loader) { fake_loader.new }

    it "builds a mappings module" do
      expect(described_class.Mappings(:my_availability, loader: loader))
        .to be_a described_class::Mappings
    end

    it "adds a :mapped_to method when included" do
      expect { model_class.include(described_class.Mappings(:my_availability, loader: loader)) }
        .to change { resource.public_methods }
        .to include :mapped_to
    end

    describe "the added :mapped_to method" do
      before do
        model_class.include(described_class.Mappings(:my_availability, loader: loader))
      end

      it "maps properties with mappings" do
        expect(resource.mapped_to("example:mapping")).to eq({
          "example:mapping#test_property" => Set.new(["etaoin"])
        })
      end

      it "does not map properies without mappings" do
        expect(resource.mapped_to("example:nomapping")).to eq({})
      end
    end
  end
end

RSpec.describe SurflinerSchema::Mappings do
  subject(:schema_module) { SurflinerSchema::Mappings.new(:my_availability, loader: double) }

  describe "#inspect" do
    it "has a readable value" do
      expect(schema_module.inspect)
        .to eq described_class.name + "(my_availability)"
    end
  end
end
