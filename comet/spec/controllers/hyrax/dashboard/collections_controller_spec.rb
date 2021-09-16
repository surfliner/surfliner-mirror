# frozen_string_literal: true

require "rails_helper"

RSpec.describe Hyrax::Dashboard::CollectionsController, storage_adapter: :memory, metadata_adapter: :test_adapter, type: :controller do
  routes { Hyrax::Engine.routes }
  let(:user) { User.create(email: "moomin@example.com") }

  describe "#new" do
    it "redirects to sign in" do
      get :new

      expect(response).to redirect_to("/users/sign_in")
    end

    context "with a logged in user" do
      before { sign_in(user) }

      let(:collection_type) { Hyrax::CollectionType.create(title: "Spec Type") }

      it "gives a succesful response" do
        get :new
        expect(response).to be_successful
      end
    end
  end

  describe "#show" do
    let(:collection) do
      c = Hyrax::PcdmCollection.new(title: ["My Collection"])
      Hyrax.persister.save(resource: c)
    end

    it "redirects to login" do
      get :show, params: {id: collection.id}

      expect(response).to redirect_to("/users/sign_in")
    end

    context "with a logged in user" do
      before { sign_in(user) }

      xit "gives a succesful response" do
        get :show, params: {id: collection.id}
        expect(response).to be_successful
      end
    end
  end
end