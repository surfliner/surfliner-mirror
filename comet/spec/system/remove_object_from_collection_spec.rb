# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Generic Objects", type: :system, js: true do
  let(:user) { User.find_or_create_by(email: "comet-admin@library.ucsb.edu") }
  before { sign_in user }

  context "remove object from collection" do
    let!(:collection_type) { Hyrax::CollectionType.create(title: "Test Type") }

    it "remove an object" do
      visit "/dashboard"
      click_on "Collections"
      find("#add-new-collection-button").click

      within("div#collectiontypes-to-create") do
        choose("Test Type")
        click_on("Create collection")
      end

      fill_in("Title", with: "Test Collection")
      click_on("Save")

      collections = Hyrax.query_service.find_all_of_model(model: Hyrax::PcdmCollection)
      col_created = collections.find do |col|
        col.title == ["Test Collection"]
      end

      visit "/concern/generic_objects/new"
      fill_in("Title", with: "Test Object")
      choose("generic_object_visibility_open")

      # ensure that the form fields are fully populated
      sleep(1.seconds)
      click_on "Save"

      click_button "Add to collection"
      select_member_of_collection(col_created)
      click_button "Save changes"

      expect(page).to have_content("Test Collection")

      visit "/dashboard/collections/#{col_created.id}"

      expect(page).to have_content("Test Object")

      click_on "Remove"

      expect(page).not_to have_content("Test Object")
    end
  end
end
