# frozen_string_literal: true

require "rails_helper"
RSpec.describe Hyrax::BatchUploadsController, storage_adapter: :memory, metadata_adapter: :test_adapter, type: :controller do
  routes { Hyrax::Engine.routes }
  let(:user) { User.find_or_create_by(email: "comet-admin@library.ucsb.edu") }
  let(:source_file) { fixture_file_upload("batch.csv", "text/csv") }
  let(:files_location) { Rails.root.join("spec", "fixtures") }

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
    context "create objects in batch" do
      before { sign_in(user) }

      it "gives a successful response" do
        expect do
          post :create, params: {batch_upload: {source_file: source_file, files_location: files_location}}
        end
          .to change { Hyrax.query_service.count_all_of_model(model: ::GenericObject) }
          .by 1
      end
    end
  end
end
