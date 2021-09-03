# frozen_string_literal: true
require "rails_helper"

RSpec.describe Hyrax::DownloadsController, storage_adapter: :memory, metadata_adapter: :test_adapter do
  routes { Hyrax::Engine.routes }
  let(:user) { User.create(email: "moomin@example.com") }
  let(:file_set) { Hyrax.persister.save(resource: Hyrax::FileSet.new) }
  let(:file) { Tempfile.new("moomin.jpg").tap { |f| f.write("def") } }
  let(:upload) { Hyrax.storage_adapter.upload(resource: file_set, file: file, original_filename: "Moomin.jpg") }

  describe "#show" do
    it "returns unauthorized if the object does not exist" do
      get :show, params: {id: "fake_id"}
      expect(response).to have_http_status(:unauthorized)
    end

    context "when the file exists" do
      it "sends the original file" do
        sign_in user
        allow(controller).to receive(:authorize!).with(:download, file_set.id).and_return true
        file_set.file_ids << upload.id
        Hyrax.persister.save(resource: file_set)
        get :show, params: {id: file_set.id}
        file.rewind
        expect(response.body).to eq file.read
      end

      context "when the user is not authorized" do
        it "returns an unauthorized HTTP status code" do
          get :show, params: {id: file_set.id}
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end
  end
end
