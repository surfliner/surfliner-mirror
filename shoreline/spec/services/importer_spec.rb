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
    let(:csv) do
      CSV.table(Rails.root.join(
        "spec",
        "fixtures",
        "csv",
        "minimal.csv"
      ), encoding: "UTF-8")
    end

    let(:zipfile) do
      Pathname.new(Rails.root.join(
        "spec",
        "fixtures",
        "shapefiles",
        "gford-20140000-010004_rivers.zip"
      )).to_s
    end

    let(:base_json) do
      {"dc_identifier_s" => "public:gford-20140000-010004_rivers",
       "layer_slug_s" => "gford-20140000-010004_rivers",
       "layer_id_s" => "public:gford-20140000-010004_rivers",
       "solr_year_i" => 2000,
       "solr_geom" => "ENVELOPE(-91.453487,-89.127493,17.838888,16.649914)",
       "solr_bboxtype" => "ENVELOPE(-91.453487,-89.127493,17.838888,16.649914)",
       "layer_geom_type_s" => "fake",
       "dc_description_s" => "This is a digital map of the rivers in the Maya Biosphere Reserve.",
       "dc_format_s" => "Shapefile",
       "dc_title_s" => "Rivers, Maya Forest, Guatemala, 2000",
       "dc_creator_sm" => ["Consejo Nacional de Áreas Protegidas (Guatemala)"],
       "dc_publisher_sm" => ["Consejo Nacional de Áreas Protegidas (Guatemala)"],
       "dc_subject_sm" => ["Maya Forest", "Rivers"],
       "dct_isPartOf_sm" => ["Maya Forest GIS"],
       "dct_spatial_sm" => ["Petén (Guatemala : Department)",
         "Guatemala",
         "Reserva de la Biosfera Maya (Guatemala)"],
       "dc_rights_s" => "Public",
       "dct_provenance_s" => "UC Santa Barbara",
       "geoblacklight_version" => "1.0",
       "solr_bboxtype__minX" => -91.453487,
       "solr_bboxtype__minY" => 16.649914,
       "solr_bboxtype__maxX" => -89.127493,
       "solr_bboxtype__maxY" => 17.838888}
    end

    let(:solr) do
      RSolr.connect(
        url: ENV["SOLR_URL"] || "http://#{ENV["SOLR_HOST"]}:#{ENV["SOLR_PORT"]}/solr/#{ENV["SOLR_COLLECTION_NAME"]}"
      )
    end

    let(:metadata) do
      described_class.hash_from_xml(file: zipfile)
        .merge(described_class.hash_from_csv(row: csv[1]))
        .merge({layer_geom_type_s: "fake"})
        .merge(described_class::EXTRA_FIELDS).reject { |_k, v| v.blank? }
    end

    context "with a 'references' column" do
      let(:expected_blob) do
        base_json.merge(
          {"dct_references_s" => '{"http://www.opengis.net/def/serviceType/ogc/wfs":"http://localhost:8080/geoserver/wfs","http://www.opengis.net/def/serviceType/ogc/wms":"http://localhost:8080/geoserver/wms","http://schema.org/downloadUrl":"https://dataverse.ucla.edu/api/v1/access/datafile/:persistentId?persistentId=doi:10.25346/S6/B5LBFD/O7ULJ5"}'}
        )
      end

      it "ingests with the correct attributes" do
        described_class.publish_to_geoblacklight(metadata: metadata)

        beep = solr.get "select",
          params: {q: "layer_slug_s:gford-20140000-010004_rivers"}

        expect(beep["response"]["docs"].first).to include(expected_blob)
      end
    end

    context "without references" do
      let(:csv) do
        CSV.table(Rails.root.join(
          "spec",
          "fixtures",
          "csv",
          "minimal_no-references.csv"
        ), encoding: "UTF-8")
      end

      let(:expected_blob) do
        base_json.merge(
          {"dct_references_s" => '{"http://www.opengis.net/def/serviceType/ogc/wfs":"http://localhost:8080/geoserver/wfs","http://www.opengis.net/def/serviceType/ogc/wms":"http://localhost:8080/geoserver/wms"}'}
        )
      end

      it "ingests with the correct attributes" do
        described_class.publish_to_geoblacklight(metadata: metadata)

        beep = solr.get "select",
          params: {q: "layer_slug_s:gford-20140000-010004_rivers"}

        expect(beep["response"]["docs"].first).to include(expected_blob)
      end
    end
  end
end
