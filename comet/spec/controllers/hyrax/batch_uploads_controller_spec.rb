# frozen_string_literal: true

require "rails_helper"
RSpec.describe Hyrax::BatchUploadsController, storage_adapter: :memory, metadata_adapter: :test_adapter, type: :controller do
  routes { Hyrax::Engine.routes }
  let(:user) { User.find_or_create_by(email: "comet-admin@library.ucsb.edu") }
  let(:source_file) { fixture_file_upload("batch.csv", "text/csv") }

  before do
    setup_workflow_for(user)
  end

  describe "#new" do
    it "redirects to sign in" do
      get :new

      expect(response).to redirect_to("/users/sign_in")
    end

    context "with a logged in user" do
      before { sign_in(user) }

      it "gives a successful response" do
        get :new
        expect(response).to be_successful
      end
    end
  end

  describe "#create" do
    context "create objects in batch with local mounted staging area" do
      let(:files_location) { Rails.root.join("spec", "fixtures") }

      before do
        Rails.application.config.staging_area_s3_enabled = false
        sign_in(user)
      end

      it "gives a successful response" do
        expect do
          post :create, params: {batch_upload: {source_file: source_file, files_location: files_location}}
        end
          .to change { Hyrax.query_service.count_all_of_model(model: ::GenericObject) }
          .by 1
      end
    end

    context "create objects in batch with S3/Minio staging area" do
      let(:fog_connection) { mock_fog_connection }
      let(:s3_bucket) { "comet-staging-area-test" }
      let(:file) { Tempfile.new("image.jpg").tap { |f| f.write("A fade image!") } }
      let(:s3_key) { "project-files/image.jpg" }

      before do
        Rails.application.config.staging_area_s3_enabled = true
        staging_area_upload(fog_connection: fog_connection,
          bucket: s3_bucket, s3_key: s3_key, source_file: file)

        sign_in(user)
      end

      it "gives a successful response" do
        expect do
          post :create, params: {batch_upload: {source_file: source_file}, files_location: "my-project/"}
        end
          .to change { Hyrax.query_service.count_all_of_model(model: ::GenericObject) }
          .by 1
      end
    end
  end
end
