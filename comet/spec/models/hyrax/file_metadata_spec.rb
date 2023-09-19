# frozen_string_literal: true

require "rails_helper"

RSpec.describe Hyrax::FileMetadata do
  describe "uri_for" do
    let(:file_use_extracted_file) { ::Valkyrie::Vocab::PCDMUse.ExtractedText }
    let(:file_use_origin_file) { ::Valkyrie::Vocab::PCDMUse.OriginalFile }
    let(:file_use_preservation_file) { ::Valkyrie::Vocab::PCDMUse.PreservationFile }
    let(:file_use_service_file) { ::Valkyrie::Vocab::PCDMUse.ServiceFile }
    let(:file_use_thumbnail_file) { ::Valkyrie::Vocab::PCDMUse.ThumbnailImage }

    it "give the :preservation_file use" do
      expect(Hyrax::FileMetadata::Use.uri_for(use: :preservation_file)).to eq(file_use_preservation_file)
    end

    it "give the :service_file use" do
      expect(Hyrax::FileMetadata::Use.uri_for(use: :service_file)).to eq(file_use_service_file)
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
  end

  describe "#type" do
    subject do
      file_metadata = described_class.new
      file_metadata.type = Hyrax::FileMetadata::Use.uri_for(use: use)
      Hyrax.persister.save(resource: file_metadata)
    end

    context ":service_file" do
      let(:use) { :service_file }

      it "has file use uri for :service_file" do
        expect(subject.type.first.to_s).to eq("http://pcdm.org/use#ServiceFile")
      end
    end
    context ":preservation_file" do
      let(:use) { :preservation_file }

      it "has file use uri for :preservation_file" do
        expect(subject.type.first.to_s).to eq("http://pcdm.org/use#PreservationFile")
      end
    end
  end
end
