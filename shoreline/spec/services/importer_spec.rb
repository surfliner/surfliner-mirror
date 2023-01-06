# frozen_string_literal: true

require "csv"
require "rails_helper"
require "rsolr"

RSpec.describe Importer do
  describe "#is_metadata_valid?" do
    let(:valid_json_fixture) do
      File.read(Rails.root.join("spec",
        "fixtures",
        "aardvark-metadata",
        "esri-feature-layer.json"))
    end
    let(:invalid_json_fixture) do
      File.read(Rails.root.join("spec",
        "fixtures",
        "aardvark-metadata",
        "esri-feature-layer-invalid.json"))
    end
    it "returns true with valid json" do
      metadata = JSON.parse(valid_json_fixture)
      expect(described_class.is_metadata_valid?(metadata)).to be_truthy
    end
    it "returns false with invalid json" do
      metadata = JSON.parse(invalid_json_fixture)
      expect(described_class.is_metadata_valid?(metadata)).to be_falsey
    end
  end
  describe "#publish_to_geoblacklight" do
    let(:shapefile) do
      Pathname.new(Rails.root.join(
        "spec",
        "fixtures",
        "shapefiles",
        "gford-20140000-010002_lakes.zip"
      )).to_s
    end

    let(:aardvark) do
      JSON.parse(File.read(Rails.root.join(
        "spec",
        "fixtures",
        "aardvark-metadata",
        "gford-20140000-010002_lakes.json"
      )))
    end

    let(:solr) do
      RSolr.connect(
        url: ENV["SOLR_URL"] || "http://#{ENV["SOLR_HOST"]}:#{ENV["SOLR_PORT"]}/solr/#{ENV["SOLR_COLLECTION_NAME"]}"
      )
    end

    let(:metadata) do
      aardvark.merge(
        {
          "layer_geom_type_s" => "fake",
          "dct_references_s" => '{"http://www.opengis.net/def/serviceType/ogc/wfs":"http://localhost:8080/geoserver/wfs","http://www.opengis.net/def/serviceType/ogc/wms":"http://localhost:8080/geoserver/wms","http://schema.org/downloadUrl":"https://dataverse.ucla.edu/api/v1/access/datafile/:persistentId?persistentId=doi:10.25346/S6/B5LBFD/O7ULJ5"}'
        }
      )
    end

    context "with a 'references' column" do
      it "ingests with the correct attributes" do
        described_class.publish_to_geoblacklight(metadata: metadata)

        beep = solr.get "select",
          params: {q: "id:gford-20140000-010002_lakes"}

        expect(beep["response"]["docs"].first).to include(metadata)
      end
    end
  end
end
