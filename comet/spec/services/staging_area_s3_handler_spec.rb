# frozen_string_literal: true

require "rails_helper"

RSpec.describe StagingAreaS3Handler do
  subject { described_class.new(connection: fog_connection, bucket: s3_bucket, prefix: "") }

  let(:fog_connection) { mock_fog_connection }
  let(:s3_bucket) { "comet-staging-area-test" }
  let(:file) { Tempfile.new("image.jpg").tap { |f| f.write("A fade image!") } }
  let(:s3_key) { "project-files/image.jpg" }

  before {
    staging_area_upload(fog_connection: fog_connection,
      bucket: s3_bucket, s3_key: s3_key, source_file: file)
  }

  it "list files" do
    expect(subject.list_files.length).to eq 1
  end

  it "list paths" do
    expect(subject.get_paths("project")).to include("project-files/")
  end

  context "S3 file URL" do
    let(:file_url) { subject.file_url(s3_key) }

    it "a valid url" do
      expect(file_url =~ URI::DEFAULT_PARSER.make_regexp).to eq 0
    end
  end

  context "copy file from S3/Minio" do
    let(:dest_file) { File.absolute_path(Tempfile.new("image.jpg")) }

    before { subject.copy_file(s3_key, dest_file) }

    it "contains the same content" do
      expect(File.read(dest_file)).to eq file.read
    end
  end
end
