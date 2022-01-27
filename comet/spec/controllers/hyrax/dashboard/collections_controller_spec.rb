# frozen_string_literal: true

require "rails_helper"
require "hyrax/specs/spy_listener"

RSpec.describe Hyrax::Dashboard::CollectionsController, storage_adapter: :memory, metadata_adapter: :test_adapter, type: :controller do
  let(:user) { User.create(email: "moomin@example.com") }

  describe "#new" do
    routes { Hyrax::Engine.routes }

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

  describe "#create" do
    routes { Hyrax::Engine.routes }

    it "redirects to sign in" do
      post :create, params: {collection: {title: ["My Title"]}}

      expect(response).to redirect_to("/users/sign_in")
    end

    context "with a logged in user" do
      before { sign_in(user) }

      let(:collection_type) { Hyrax::CollectionType.create(title: "Spec Type") }

      it "gives a succesful response" do
        expect do
          post :create, params: {collection: {title: ["My Title"]},
                                 collection_type_gid: collection_type.to_global_id}
        end
          .to change { Hyrax.query_service.count_all_of_model(model: Hyrax::PcdmCollection) }
          .by 1
      end
    end
  end

  describe "#show" do
    routes { Hyrax::Engine.routes }

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

  describe "#publish" do
    let(:collection_type) { Hyrax::CollectionType.create(title: "Test Type") }
    let(:collection_type_gid) { collection_type.to_global_id.to_s }
    let(:collection) do
      col = Hyrax::PcdmCollection.new(title: ["Test Collection"], collection_type_gid: collection_type_gid)
      Hyrax.persister.save(resource: col)
    end

    let(:object_a) do
      obj_a = ::GenericObject.new(title: ["Test Object A"], member_of_collection_ids: [collection.id])
      Hyrax.persister.save(resource: obj_a)
    end

    let(:object_b) do
      obj_b = ::GenericObject.new(title: ["Test Object B"], member_of_collection_ids: [collection.id])
      Hyrax.persister.save(resource: obj_b)
    end

    before {
      sign_in(user)

      Hyrax::Collections::PermissionsCreateService.create_default(collection: collection, creating_user: user)
      collection.permission_manager.read_users += [user.user_key]
      collection.permission_manager.edit_users += [user.user_key]
      collection.permission_manager.acl.save

      Hyrax.index_adapter.save(resource: collection)
      Hyrax.index_adapter.save(resource: object_a)
      Hyrax.index_adapter.save(resource: object_b)
      Hyrax.publisher.subscribe(listener)
    }

    after { Hyrax.publisher.unsubscribe(listener) }

    let(:listener) do
      klass = Class.new do
        def initialize
          @event = nil
        end

        def on_collection_publish(event)
          @event = event
        end

        def collection_publish
          @event
        end
      end

      klass.new
    end

    context "Publish collection" do
      it "publishes an event" do
        expect { post :publish, params: {id: collection.id} }
          .to change { listener.collection_publish&.payload }
          .to include(collection: collection)
      end
    end
  end
end
