# frozen_string_literal: true

require "csv"
require "rails_helper"
require "rsolr"

RSpec.describe Importer do
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

    let(:solr) do
      RSolr.connect(
        url: ENV["SOLR_URL"] || "http://#{ENV["SOLR_HOST"]}:#{ENV["SOLR_PORT"]}/solr/#{ENV["SOLR_CORE_NAME"]}"
      )
    end

    let(:metadata) do
      described_class.hash_from_xml(file: zipfile)
        .merge(described_class.hash_from_csv(row: csv[1]))
        .merge({layer_geom_type_s: "fake"})
        .merge(described_class::EXTRA_FIELDS).reject { |_k, v| v.blank? }
    end

    let(:expected_blob) do
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
       "dc_rights_s" => "Restricted",
       "dct_references_s" => '{"http://www.opengis.net/def/serviceType/ogc/wfs":"http://localhost:8080/geoserver/wfs", "http://www.opengis.net/def/serviceType/ogc/wms":"http://localhost:8080/geoserver/wms"}',
       "geoblacklight_version" => "1.0",
       "solr_bboxtype__minX" => -91.453487,
       "solr_bboxtype__minY" => 16.649914,
       "solr_bboxtype__maxX" => -89.127493,
       "solr_bboxtype__maxY" => 17.838888}
    end

    it "ingests with the correct attributes" do
      described_class.publish_to_geoblacklight(metadata: metadata)

      beep = solr.get "select",
        params: {q: "layer_slug_s:gford-20140000-010004_rivers"}

      expect(beep["response"]["docs"].first).to include expected_blob
    end
  end
end
