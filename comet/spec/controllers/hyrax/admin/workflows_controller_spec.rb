# frozen_string_literal: true

require "rails_helper"

RSpec.describe Hyrax::Admin::WorkflowsController, storage_adapter: :memory, metadata_adapter: :test_adapter, type: :controller do
  let(:user) { User.find_or_create_by(email: "comet-admin@library.ucsb.edu") }

  before do
    setup_workflow_for(user)
    sign_in user
  end

  describe "#index" do
    routes { Hyrax::Engine.routes }

    it "is successful" do
      expect(controller).to receive(:add_breadcrumb).with("Home", root_path)
      expect(controller).to receive(:add_breadcrumb).with("Dashboard", dashboard_path)
      expect(controller).to receive(:add_breadcrumb).with("Tasks", "#")
      expect(controller).to receive(:add_breadcrumb).with("Review Submissions", "/admin/workflows")

      get :index
      expect(response).to be_successful
    end

    context "with query keyword q and batch_id" do
      it "is successful" do
        get :index, params: {q: "any keywords", batch: "fade_batch_id"}
        expect(response).to be_successful
      end
    end
  end
end
