# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Generic Objects", type: :system, js: true, storage_adapter: :memory, metadata_adapter: :test_adapter do
  let(:user) { User.find_or_create_by(email: "comet-admin@library.ucsb.edu") }
  before { sign_in user }

  context "during object creation" do
    xit "can create a new object and assign a Collection to it" do
      visit "/dashboard/my/works"
      click_on "Add new work"
      fill_in("Title", with: "My Title")
      click_on "Relationships"
      click_on "Select a collection"
      # TODO: type in "My Collection"
      # TODO: expect a result
    end
  end

  context "after object creation" do
    let!(:collection_type) { Hyrax::CollectionType.create(title: "Spec Type") }

    it "can assign a Collection to it" do
      visit "/dashboard"
      click_on "Collections"
      expect(page).to have_link("New Collection")

      click_on "New Collection"
      fill_in("Title", with: "Test Collection")

      click_on("Save")
      persisted_collections = Hyrax.query_service.find_all_of_model(model: Hyrax::PcdmCollection)
      persisted_collection = persisted_collections.find do |col|
        col.title == ["Test Collection"]
      end
      visit "/dashboard/my/works"
      click_on "Add new work"

      fill_in("Title", with: "My Title")
      choose("generic_object_visibility_open")

      # ensure that the form fields are fully populated
      sleep(1.seconds)
      click_on "Save"

      click_button "Add to collection"
      select_member_of_collection(persisted_collection)
      click_button "Save changes"

      gobjs = Hyrax.query_service.find_all_of_model(model: GenericObject)
      persisted_object = gobjs.find do |gob|
        gob.title == ["My Title"]
      end
      expect(persisted_object.member_of_collection_ids).to eq([persisted_collection.id])

      visit "/dashboard"
      click_on "Collections"
      click_on("Display all details of Test Collection")

      expect(page).to have_content("Test Collection")
      expect(page).to have_content("My Title")
    end

    it "can assign multiple Collections to it" do
      visit "/dashboard"
      click_on "Collections"
      expect(page).to have_link("New Collection")

      click_on "New Collection"
      fill_in("Title", with: "Test Collection 1")

      click_on("Save")

      visit "/dashboard"
      click_on "Collections"
      expect(page).to have_link("New Collection")

      click_on "New Collection"
      fill_in("Title", with: "Test Collection 2")

      click_on("Save")

      expect(page).to have_content("Test Collection 2")

      persisted_collections = Hyrax.query_service.find_all_of_model(model: Hyrax::PcdmCollection)
      persisted_collection1 = persisted_collections.find do |col|
        col.title == ["Test Collection 1"]
      end
      persisted_collection2 = persisted_collections.find do |col|
        col.title == ["Test Collection 2"]
      end

      visit "/dashboard/my/works"
      click_on "Add new work"

      fill_in("Title", with: "My Title")
      choose("generic_object_visibility_open")

      # ensure that the form fields are fully populated
      sleep(1.seconds)
      click_on "Save"

      click_button "Add to collection"
      select_member_of_collection(persisted_collection1)
      click_button "Save changes"

      gobjs = Hyrax.query_service.find_all_of_model(model: GenericObject)
      persisted_object = gobjs.find do |gob|
        gob.title == ["My Title"]
      end

      visit main_app.hyrax_generic_object_path(id: persisted_object.id.to_s,
        locale: "en")
      click_button "Add to collection"
      select_member_of_collection(persisted_collection2)
      click_button "Save changes"

      expect(persisted_object.member_of_collection_ids).to contain_exactly(persisted_collection1.id, persisted_collection2.id)
    end
  end
end
