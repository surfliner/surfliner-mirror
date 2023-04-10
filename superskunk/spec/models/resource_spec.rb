require "rails_helper"

RSpec.describe Superskunk::Resource do
  describe "a Valkyrie‐generated subclass" do
    subject(:object) do
      # Use the resource factory to generate the resource to ensure that the
      # resource class resolver works as intended.
      Superskunk.metadata_adapter.resource_factory.to_resource(object: {
        internal_resource: "GenericObject",
        metadata: {}
      })
    end

    it "has some attributes" do
      object.title = "abc"
      expect(object).to have_attributes(
        internal_resource: "GenericObject",
        title: ["abc"]
      )
    end

    it "has a :mapped_to method" do
      expect(object.respond_to?(:mapped_to)).to be true
    end
  end
end
