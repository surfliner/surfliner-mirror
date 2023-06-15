# frozen_string_literal: true

require "rails_helper"

RSpec.describe Hyrax::DownloadsController, :integration do
  routes { Hyrax::Engine.routes }
  let(:user) { User.create(email: "moomin@example.com") }
  let(:file_set) { Hyrax.persister.save(resource: Hyrax::FileSet.new) }
  let(:file) { Tempfile.new("moomin.jpg").tap { |f| f.write("moomin picture") } }
  let(:upload) { Hyrax.storage_adapter.upload(resource: file_set, file: file, original_filename: "Moomin.jpg") }

  let(:file_metadata) do
    Hyrax::FileMetadata.new(file_identifier: upload.id, alternate_ids: upload.id, original_filename: "Moomin.jpg")
  end

  before do
    file_set.file_ids << upload.id
    Hyrax.persister.save(resource: file_set)
    Hyrax.persister.save(resource: file_metadata)
  end

  describe "#show" do
    it "returns unauthorized without a logged in user" do
      get :show, params: {id: "fake_id"}
      expect(response).to have_http_status(:unauthorized)
    end

    context "when the user is logged in" do
      before do
        sign_in user

        Hyrax::AccessControlList.new(resource: file_set)
          .grant(:read)
          .to(user)
          .save
      end

      it "sends the original file" do
        get :show, params: {id: file_set.id}

        expect(Net::HTTP.get(URI(response.location))).to eq "moomin picture"
      end

      context "and there are multiple file members in the FileSet" do
        let(:text_file) { Tempfile.new("moomin.txt").tap { |f| f.write("description of moomin.jpg") } }
        let(:text_upload) { Hyrax.storage_adapter.upload(resource: file_set, file: text_file, original_filename: "moomin.txt") }

        let(:text_file_metadata) do
          Hyrax::FileMetadata
            .new(file_identifier: text_upload.id,
              alternate_ids: text_upload.id,
              original_filename: "moomin.txt",
              type: Hyrax::FileMetadata::Use.uri_for(use: :extracted_file))
        end

        before do
          file_set.file_ids << text_upload.id
          Hyrax.persister.save(resource: file_set)
          Hyrax.persister.save(resource: text_file_metadata)
        end

        it "redirects to a presigned S3 url" do
          get :show, params: {id: file_set.id}

          expect(response)
            .to have_attributes(status: 302, location: include("X-Amz-Signature="))
        end

        it "downloads the original by default" do
          get :show, params: {id: file_set.id}
          expect(Net::HTTP.get(URI(response.location))).to eq "moomin picture"
        end

        it "resolves download requests by use" do
          get :show, params: {id: file_set.id, use: "extracted_file"}
          expect(Net::HTTP.get(URI(response.location))).to eq "description of moomin.jpg"
        end

        it "populates content disposition from selected file" do
          get :show, params: {id: file_set.id, use: "extracted_file"}

          expect(response.location)
            .to include("response-content-disposition=attachment%3B%20filename%3D%22moomin.txt")
        end

        it "populates mime_type from selected file" do
          get :show, params: {id: file_set.id, use: "extracted_file"}

          expect(response.location).to include("application%2Foctet-stream")
        end
      end
    end
  end
end
