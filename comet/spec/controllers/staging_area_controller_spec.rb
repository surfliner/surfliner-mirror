# frozen_string_literal: true

require "rails_helper"

RSpec.describe StagingAreaController do
  let(:mock_connection) { mock_fog_connection }
  let(:s3_bucket) { "comet-staging-area-test" }
  let(:s3_key) { "project-files/image.jpg" }
  let(:file) { Tempfile.new("image.jpg").tap { |f| f.write("A fade image!") } }

  before do
    staging_area_upload(fog_connection: mock_connection,
      bucket: s3_bucket, s3_key: s3_key, source_file: file)

    mock_handler = StagingAreaS3Handler.new(connection: mock_connection,
      bucket: s3_bucket, prefix: "")
    Rails.application.config.staging_area_s3_handler = mock_handler
  end

  describe "#index" do
    it "returns unauthorized if the object does not exist" do
      get :index
      expect(response).to have_http_status(200)
    end

    context "with parameter q" do
      it "gives the directory" do
        get :index, params: {q: "project"}

        expect(JSON.parse(response.body).first.to_h).to include("id" => "project-files/")
      end
    end
  end
end
