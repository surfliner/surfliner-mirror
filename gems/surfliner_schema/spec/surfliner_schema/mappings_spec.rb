# frozen_string_literal: true

require "spec_helper"

RSpec.describe SurflinerSchema do
  describe "::Mappings" do
    let(:reader_class) do
      Class.new(SurflinerSchema::Reader) do
        def properties(availability:)
          return unless availability == :my_availability
          {
            test_field: SurflinerSchema::Property.new(
              name: :test_field,
              display_label: "Test Field",
              available_on: [:my_availability],
              mapping: {
                "example:mapping" => ["example:mapping#test_property"]
              }
            )
          }
        end

        def resource_classes
          {
            my_availability: SurflinerSchema::ResourceClass.new(
              name: :my_availability,
              display_label: "My Availability"
            )
          }
        end
      end
    end
    let(:model_class) { reader_class.new.resolve(:my_availability) }
    let(:resource) { model_class.new(test_field: "etaoin") }

    describe "the added :mapped_to method" do
      it "maps properties with mappings" do
        expect(resource.mapped_to("example:mapping")).to eq({
          "example:mapping#test_property" => Set.new([RDF::Literal("etaoin")])
        })
      end

      it "does not map properies without mappings" do
        expect(resource.mapped_to("example:nomapping")).to eq({})
      end
    end
  end
end
