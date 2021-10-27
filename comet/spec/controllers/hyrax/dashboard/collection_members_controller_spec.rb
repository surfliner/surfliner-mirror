# frozen_string_literal: true

require "rails_helper"
RSpec.describe Hyrax::Dashboard::CollectionMembersController, storage_adapter: :memory, metadata_adapter: :test_adapter, type: :controller do

  routes { Hyrax::Engine.routes }
  let(:user) { User.create(email: "moomin@example.com") }

  before { sign_in(user) }

  let(:collection) { Hyrax::PcdmCollection.new(title: ['Test Collection'], collection_type_gid: collection_type_gid )
  let(:collection_type) { Hyrax::CollectionType.create(title: "Spec Type") }
  let(:collection_type_gid) { collection_type.to_global_id.to_s }

  describe '#update_members' do
    let(:members_to_add) { [collection_member] }

    let(:parameters) do
      { id: collection,
        collection: { members: 'add' },
        batch_document_ids: members_to_add.map(&:id) }
    end

    let(:collection_member) do
      Hyrax::PcdmCollection.new(title: ['Test Collection'],
                                collection_type_gid: collection_type_gid )
    end

    it 'can add a collection member to the collection' do
      expect { post :update_members, params: parameters }
        .to change { queries.find_members_of(collection: collection.valkyrie_resource).map(&:id) }
        .from(be_empty)
        .to contain_exactly(collection_member)
    end
  end
end
