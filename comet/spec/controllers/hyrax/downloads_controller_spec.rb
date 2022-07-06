# frozen_string_literal: true

require "rails_helper"

RSpec.describe Hyrax::DownloadsController, :integration do
  routes { Hyrax::Engine.routes }
  let(:user) { User.create(email: "moomin@example.com") }
  let(:file_set) { Hyrax.persister.save(resource: Hyrax::FileSet.new) }
  let(:file) { Tempfile.new("moomin.jpg").tap { |f| f.write("def") } }
  let(:upload) { Hyrax.storage_adapter.upload(resource: file_set, file: file, original_filename: "Moomin.jpg") }

  let(:file_metadata) do
    Hyrax::FileMetadata.new(file_identifier: upload.id, alternate_ids: upload.id)
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
        file.rewind
        expect(response.body).to eq file.read
      end
    end
  end
end
