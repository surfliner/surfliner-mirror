require "rails_helper"

RSpec.describe AardvarkSerializer do
  subject(:serialized_aardvark) { described_class.serialize(resource: resource, profile: profile, agent: agent) }
  let(:agent) { "surfliner.superskunk.test_suite" }
  let(:persister) { Valkyrie::MetadataAdapter.find(:comet_metadata_store).persister }
  let(:profile) { "tag:surfliner.gitlab.io,2022:api/aardvark" }

  context "with all bounding box values supplied" do
    let(:title) { "A geospatial object with all bbox values" }
    let(:resource) {
      persister.save(resource: GeospatialObject.new(title: [title],
        bounding_box_west: "-93",
        bounding_box_east: "-86",
        bounding_box_north: "21",
        bounding_box_south: "13"))
    }
    it "populates the dcat_bbox and locn_geometry properties" do
      expect(serialized_aardvark[:dcat_bbox]).to eq("ENVELOPE(-93,-86,21,13)")
      expect(serialized_aardvark[:locn_geometry]).to eq("ENVELOPE(-93,-86,21,13)")
    end
  end

  context "with some bounding box values missing" do
    let(:title) { "A geospatial object without all bbox values" }
    let(:resource) {
      persister.save(resource: GeospatialObject.new(title: [title],
        bounding_box_west: "-93",
        bounding_box_south: "13"))
    }
    it "does not populate the dcat_bbox and locn_geometry properties" do
      expect(serialized_aardvark[:dcat_bbox]).to be_nil
      expect(serialized_aardvark[:locn_geometry]).to be_nil
    end
  end

  context "with object being part of a collection" do
    let(:title) { "A geospatial object with a parent collection" }
    let(:resource) {
      persister.save(resource: GeospatialObject.new(title: [title], member_of_collection_ids: ["2"]))
    }
    it "populates the pcdm_memberOf_sm property with collection id(s)" do
      expect(serialized_aardvark[:pcdm_memberOf_sm]).to eq(["2"])
    end
  end

  context "with object not being part of any collection" do
    let(:title) { "A geospatial object without a parent collection" }
    let(:resource) {
      persister.save(resource: GeospatialObject.new(title: [title]))
    }
    it "does not populate the pcdm_memberOf_sm property" do
      expect(serialized_aardvark[:pcdm_memberOf_sm]).to be_nil
    end
  end
end
