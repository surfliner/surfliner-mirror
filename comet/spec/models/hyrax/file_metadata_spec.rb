# frozen_string_literal: true

require "rails_helper"

RSpec.describe Hyrax::FileMetadata do
  describe "uri_for" do
    let(:file_use_geoshape_file) { ::Valkyrie::Vocab::PCDMUseExtesion.GeoShapeFile }
    let(:file_use_origin_file) { ::Valkyrie::Vocab::PCDMUse.OriginalFile }
    let(:file_use_extracted_file) { ::Valkyrie::Vocab::PCDMUse.ExtractedText }
    let(:file_use_thumbnail_file) { ::Valkyrie::Vocab::PCDMUse.ThumbnailImage }
    let(:file_use_uri) { RDF::URI.new("http://pcdm.org/use#GeoShapeFile") }

    it "give the : geoshape_file use" do
      expect(Hyrax::FileMetadata::Use.uri_for(use: :geoshape_file)).to eq(file_use_geoshape_file)
    end

    it "give the :original_file use" do
      expect(Hyrax::FileMetadata::Use.uri_for(use: :original_file)).to eq(file_use_origin_file)
    end

    it "give the ::extracted_file use" do
      expect(Hyrax::FileMetadata::Use.uri_for(use: :extracted_file)).to eq(file_use_extracted_file)
    end

    it "give the :thumbnail_file use" do
      expect(Hyrax::FileMetadata::Use.uri_for(use: :thumbnail_file)).to eq(file_use_thumbnail_file)
    end

    it "give the correct file use URI" do
      expect(Hyrax::FileMetadata::Use.uri_for(use: file_use_uri)).to eq(file_use_uri)
    end
  end

  describe "#type" do
    subject do
      file_metadata = described_class.new
      file_metadata.type = Hyrax::FileMetadata::Use.uri_for(use: use)
      Hyrax.persister.save(resource: file_metadata)
    end

    context ":geoshape_file" do
      let(:use) { :geoshape_file }

      it "has file use uri for:geoshape_file" do
        expect(subject.type.first.to_s).to eq("http://pcdm.org/use#GeoShapeFile")
      end
    end
  end
end
