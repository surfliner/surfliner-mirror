# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Objects", type: :system, js: true do
  let(:collection) do
    col = Hyrax::PcdmCollection.new(title: ["Test Collection for Object Assignment"],
      collection_type_gid: collection_type.to_global_id.to_s)
    col = Hyrax.persister.save(resource: col)
    col
  end

  let(:collection_type) do
    type = Hyrax::CollectionType.create(title: "Spec Type")
    Hyrax::CollectionTypeParticipant.create(hyrax_collection_type: type, agent_id: user.id, agent_type: "user", access: Hyrax::CollectionTypeParticipant::MANAGE_ACCESS)
    type
  end
  let(:user) { User.find_or_create_by(email: "comet-admin@library.ucsb.edu") }

  before do
    collection # create the collection explictly
    sign_in user
  end

  context "from the new object form" do
    it "can create a new object and assign a Collection to it" do
      visit "/concern/generic_objects/new"

      fill_in("Title", with: "My Title")
      click_on "Relationships"
      click_on "Select a collection"
      # TODO: type in "My Collection"
      # TODO: expect a result
    end
  end

  context "from the object show page" do
    let(:object) do
      obj = GenericObject.new(title: "Object Added to Collection by Spec",
        visibility: "open",
        edit_users: [user])
      obj = Hyrax.persister.save(resource: obj)
      Hyrax.index_adapter.save(resource: obj)
      obj
    end

    it "can assign a Collection to it" do
      visit main_app.hyrax_generic_object_path(id: object.id, locale: "en")

      click_button "Add to collection"
      select_member_of_collection(collection)
      click_button "Save changes"

      expect(object.member_of_collection_ids).to contain_exactly collection.id

      visit "/dashboard/collections/#{collection.id}"

      expect(page).to have_content("Test Collection for Object Assignment")
      expect(page).to have_content("Object Added to Collection by Spec")
    end

    it "can assign multiple Collections to it" do
      col = Hyrax::PcdmCollection.new(title: ["Another Test Collection for Object Assignment"],
        collection_type_gid: collection_type.to_global_id.to_s)
      other_collection = Hyrax.persister.save(resource: col)

      visit main_app.hyrax_generic_object_path(id: object.id, locale: "en")

      click_button "Add to collection"
      select_member_of_collection(collection)
      click_button "Save changes"

      visit main_app.hyrax_generic_object_path(id: object.id, locale: "en")

      click_button "Add to collection"
      select_member_of_collection(other_collection)
      click_button "Save changes"

      expect(persisted_object.member_of_collection_ids)
        .to contain_exactly(collection.id, other_collection.id)
    end
  end
end
