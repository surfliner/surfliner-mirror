# frozen_string_literal: true

require "spec_helper"

RSpec.describe StagingAreaS3Handler do
  subject { Rails.application.config.staging_area_s3_handler }

  let(:s3_bucket) { ENV.fetch("STAGING_AREA_S3_BUCKET") }
  let(:file) { Tempfile.new("image.jpg").tap { |f| f.write("A fade image!") } }
  let(:s3_key) { "project-files/image.jpg" }

  before { staging_area_upload(bucket: s3_bucket, s3_key: s3_key, source_file: file) }

  it "list files" do
    expect(subject.list_files).not_to be_empty
  end

  context "download file from S3/Minio with S3 file URL" do
    let(:dest_file) { File.absolute_path(Tempfile.new("image.jpg")) }

    before { download_s3_file(s3_url: subject.file_url(s3_key), dest_file: dest_file) }

    it "a valid S3 url" do
      expect(File.open(dest_file).read).to eq file.read
    end
  end

  context "copy file from S3/Minio" do
    let(:dest_file) { File.absolute_path(Tempfile.new("image.jpg")) }

    before { subject.copy_file(s3_key, dest_file) }

    it "contains the same content" do
      expect(File.open(dest_file).read).to eq file.read
    end
  end
end
