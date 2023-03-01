# frozen_string_literal: true

require "rails_helper"
RSpec.describe Hyrax::Dashboard::CollectionMembersController, storage_adapter: :memory, metadata_adapter: :test_adapter, type: :controller do
  routes { Hyrax::Engine.routes }
  let(:user) { User.create(email: "comet-admin@library.ucsd.edu") }

  let(:collection) do
    FactoryBot.valkyrie_create(
      :collection,
      :with_index,
      :with_permission_template,
      edit_users: [user.user_key],
      read_users: [user.user_key],
      title: "Test Collection",
      user: user
    )
  end

  before { sign_in(user) }

  describe "#update_members" do
    let(:members_to_add) { [collection_member, other_member] }

    let(:parameters) do
      {id: collection,
       collection: {members: "add"},
       batch_document_ids: members_to_add.map(&:id)}
    end

    let(:collection_member) do
      FactoryBot.valkyrie_create(
        :collection,
        title: "Test Sub Collection"
      )
    end

    let(:other_member) do
      FactoryBot.valkyrie_create(
        :collection,
        title: "Test Sub Collection 2"
      )
    end

    it "can add a collection member to the collection" do
      expect { post :update_members, params: parameters }
        .to change { Hyrax.custom_queries.find_members_of(collection: collection).map(&:id) }
        .from(be_empty)
        .to contain_exactly(collection_member.id, other_member.id)
    end
  end
end
