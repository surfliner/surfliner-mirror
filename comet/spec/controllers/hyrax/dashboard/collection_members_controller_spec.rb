# frozen_string_literal: true

require "rails_helper"
RSpec.describe Hyrax::Dashboard::CollectionMembersController, storage_adapter: :memory, metadata_adapter: :test_adapter, type: :controller do
  routes { Hyrax::Engine.routes }

  let(:collection) do
    Hyrax.persister.save(resource: Hyrax::PcdmCollection.new(title: ['Test Collection'],
                                                             collection_type_gid: collection_type_gid))
  end

  let(:collection_type) { Hyrax::CollectionType.create(title: "Spec Type") }
  let(:collection_type_gid) { collection_type.to_global_id.to_s }
  let(:user) { User.create(email: "moomin@example.com") }

  before { sign_in(user)}

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
        .to change { Hyrax.custom_queries.find_members_of(collection: collection).map(&:id) }
        .from(be_empty)
        .to contain_exactly(collection_member)
    end
  end
end
