require "rails_helper"

RSpec.describe AardvarkSerializer do
  subject(:serialized_aardvark) { described_class.serialize(resource: resource, profile: profile, agent: agent) }
  let(:agent) { "surfliner.superskunk.test_suite" }
  let(:persister) { Valkyrie::MetadataAdapter.find(:comet_metadata_store).persister }
  let(:profile) { "tag:surfliner.gitlab.io,2022:api/aardvark" }

  context "with a date" do
    let(:title) { "A geospatial object with a date" }
    let(:resource) {
      persister.save(resource: GeospatialObject.new(title: [title],
        date_index_geo: "1969"))
    }
    it "knows what an EDTF literal is" do
      expect(resource.date_index_geo.first.object).to be_a Date
    end
  end

  context "with a provided resource type" do
    let(:title) { "A geospatial object with a provided resource type" }
    let(:resource) {
      persister.save(resource: GeospatialObject.new(title: [title],
        resource_type_geo: "Point Data"))
    }
    it "populates the dcat_bbox and locn_geometry properties" do
      expect(serialized_aardvark[:gbl_resourceType_sm]).to eq(["Point Data"])
    end
  end

  context "with a provided ark" do
    let(:title) { "A geospatial object with an ARK" }
    let(:resource) {
      persister.save(resource: GeospatialObject.new(title: [title],
        ark: "14697/b12345x"))
    }
    it "populates the id property" do
      expect(serialized_aardvark[:id]).to eq("14697/b12345x")
    end
  end

  context "without a provided ark" do
    let(:title) { "A geospatial object without an ARK" }
    let(:resource) {
      persister.save(resource: GeospatialObject.new(title: [title],
        id: "12345"))
    }
    it "populates the id property with the resource id" do
      expect(serialized_aardvark[:id]).to eq("12345")
    end
  end

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

  context "with an object that has FileSets" do
    let(:query_service) { Superskunk.comet_query_service }
    let(:title) { "A geospatial object without a parent collection" }
    let(:fileset) {
      persister.save(resource: Hyrax::FileSet.new(title: ["A FileSet"]))
    }
    let(:resource) {
      persister.save(resource: GeospatialObject.new(title: [title], member_ids: [fileset.id]))
    }
    it "provides a serialized set of _file_urls" do
      expected_fileset_url = "#{ENV.fetch("COMET_BASE", "http://comet:3000")}/downloads/#{fileset.id}?use=service_file"
      expect(serialized_aardvark[:_file_urls]).to eq([expected_fileset_url])
    end
  end

  context "with an m3 schema that specifies ogm_provider_name" do
    let(:title) { "A geospatial object with an ogm_provider_name specified" }
    let(:resource) {
      persister.save(resource: GeospatialObject.new(title: [title]))
    }
    it "populates the schema_provider_s property" do
      expect(serialized_aardvark[:schema_provider_s]).to eq("Surfliner Team")
    end
  end

  context "with an iso639-1 language provided" do
    let(:title) { "A geospatial object with an iso639-1 language specified" }
    let(:resource) {
      persister.save(resource: GeospatialObject.new(title: [title], language_geo: ["en"]))
    }
    it "populates the dct_language_sm property with mapped iso639-2 values" do
      expect(serialized_aardvark[:dct_language_sm]).to eq(["eng"])
    end
  end

  context "with invalid iso639-1 languages provided" do
    let(:title) { "A geospatial object with an invalid iso639-1 language specified" }
    let(:resource) {
      persister.save(resource: GeospatialObject.new(title: [title], language_geo: ["en", "12"]))
    }
    it "populates the dct_language_sm property without invalid iso639-1 values" do
      expect(serialized_aardvark[:dct_language_sm]).to eq(["eng"])
    end
  end

  context "with no iso639-1 language provided" do
    let(:title) { "A geospatial object without an iso639-1 language specified" }
    let(:resource) {
      persister.save(resource: GeospatialObject.new(title: [title]))
    }
    it "does not populate the dct_language_sm property" do
      expect(serialized_aardvark[:dct_language_sm]).to be_nil
    end
  end
end
