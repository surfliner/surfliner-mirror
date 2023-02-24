# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Generic Objects", type: :system, js: true do
  let(:user) { User.find_or_create_by(email: "comet-admin@library.ucsb.edu") }
  before { sign_in user }

  context "remove object from collection" do
    let(:collection) do
      FactoryBot.valkyrie_create(:collection,
        :with_permission_template,
        title: "Test Collection",
        user: user)
    end

    before { collection } # create explictly

    it "remove an object" do
      visit "/concern/generic_objects/new"
      fill_in("Title", with: "Test Object")
      choose("generic_object_visibility_open")

      within("div#savewidget") do
        expect(page).to have_content "Save"
        click_on "Save"
      end

      click_button "Add to collection"
      select_member_of_collection(collection)
      click_button "Save changes"

      expect(page).to have_content("Test Collection")

      visit "/dashboard/collections/#{collection.id}"

      expect(page).to have_content("Test Object")

      click_on "Remove"

      visit "/dashboard/collections/#{collection.id}"
      expect(page).not_to have_content("Test Object")
    end
  end
end
