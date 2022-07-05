# frozen_string_literal: true

require "rails_helper"

RSpec.describe Hyrax::DownloadsController, storage_adapter: :memory, metadata_adapter: :test_adapter do
  routes { Hyrax::Engine.routes }
  let(:user) { User.create(email: "moomin@example.com") }
  let(:file_set_metadata) { Hyrax::FileMetadata.for(file: file) }
  let(:file_set) { Hyrax.persister.save(resource: Hyrax::FileSet.new) }
  let(:file) { Tempfile.new("moomin.jpg").tap { |f| f.write("def") } }
  let(:upload) { Hyrax.storage_adapter.upload(resource: file_set, file: file, original_filename: "Moomin.jpg") }

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
        allow(file).to receive(:original_filename).and_return("Moomin.jpg")
        allow(file).to receive(:content_type).and_return("image/jpeg")
        file_set.file_ids << upload.id
        Hyrax.persister.save(resource: file_set)
        file_set_metadata.file_identifier = upload.id
        file_set_metadata.file_set_id = file_set.id
        file_set_metadata.size = upload.size
        file_set_metadata.id = upload.id
        Hyrax.persister.save(resource: file_set_metadata)
        get :show, params: {id: file_set.id}
        file.rewind
        expect(response.body).to eq file.read
      end
    end
  end
end
