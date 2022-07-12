# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Collections", type: :system, js: true do
  let(:user) { User.find_or_create_by(email: "comet-admin@library.ucsb.edu") }

  before { sign_in user }

  it "can create a new collection and add object" do
    visit "/admin/collection_types"
    click_on "Create new collection type"
    fill_in("Type name", with: "Curated Collection")
    click_on "Save"

    visit "/dashboard"
    click_on "Collections"
    expect(page).to have_link("New Collection")

    click_on "New Collection"
    fill_in("Title", with: "System Spec Collection")

    expect { click_on("Save") }
      .to change { Hyrax.query_service.count_all_of_model(model: Hyrax::PcdmCollection) }
      .by 1

    expect(page).to have_content("Collection was successfully created.")
    expect(page).to have_content("System Spec Collection")

    # TODO: teach collection controller to use a new non-Solr presenter
    click_on("Display all details of System Spec Collection")
    expect(page).to have_content("System Spec Collection")
  end

  context "nested collection" do
    let(:user) { User.create(email: "comet-admin@library.ucsd.edu") }

    let(:collection_type) { Hyrax::CollectionType.create(title: "Spec Type") }
    let(:collection_type_gid) { collection_type.to_global_id.to_s }
    let(:collection) do
      Hyrax.persister.save(resource: Hyrax::PcdmCollection.new(title: ["Test Collection"], collection_type_gid: collection_type_gid))
    end
    let(:nested_collection) do
      Hyrax.persister.save(resource: Hyrax::PcdmCollection.new(title: ["Nested Collection"], collection_type_gid: collection_type_gid))
    end
    let(:another_nested_collection) do
      Hyrax.persister.save(resource: Hyrax::PcdmCollection.new(title: ["Another Nested Collection"], collection_type_gid: collection_type_gid))
    end

    before {
      Hyrax::Collections::PermissionsCreateService.create_default(collection: collection, creating_user: user)
      collection.permission_manager.read_users += [user.user_key]
      collection.permission_manager.edit_users += [user.user_key]
      collection.permission_manager.acl.save

      Hyrax::Collections::CollectionMemberService.add_members_by_ids(collection_id: collection.id,
        new_member_ids: [nested_collection.id, another_nested_collection.id],
        user: user)

      Hyrax.index_adapter.save(resource: collection)

      sign_in(user)
    }

    it "shows the nested collection" do
      visit visit "/dashboard/collections/#{collection.id}"

      expect(page).to have_content("Test Collection")
      expect(page).to have_content("Nested Collection")
      expect(page).to have_content("Another Nested Collection")
    end
  end

  context "collection object members" do
    let(:user) { User.create(email: "comet-admin@library.ucsd.edu") }

    let(:collection_type) { Hyrax::CollectionType.create(title: "Test Type") }
    let(:collection_type_gid) { collection_type.to_global_id.to_s }
    let(:collection) do
      col = Hyrax::PcdmCollection.new(title: ["Test Collection"], collection_type_gid: collection_type_gid)
      Hyrax.persister.save(resource: col)
    end

    let(:object_a) do
      obj_a = ::GenericObject.new(title: ["Test Member Object A"], member_of_collection_ids: [collection.id])
      Hyrax.persister.save(resource: obj_a)
    end

    let(:object_b) do
      obj_b = ::GenericObject.new(title: ["Test Member Object B"], member_of_collection_ids: [collection.id])
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
    }

    it "display object members to authorized user" do
      visit "/dashboard/collections/#{collection.id}"

      expect(page).to have_content("Test Collection")
      expect(page).to have_content("Test Member Object A")
      expect(page).to have_content("Test Member Object B")
    end
  end
end
