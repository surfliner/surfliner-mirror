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
    xit "can assign a Collection to it" do
      visit "/dashboard"
      click_on "Collections"
      expect(page).to have_link("New Collection")

      click_on "New Collection"
      fill_in("Title", with: "Test Collection")

      click_on("Save")
      persisted_collection = Hyrax.query_service.find_all_of_model(model: Hyrax::PcdmCollection).first
      visit "/dashboard/my/works"
      click_on "Add new work"

      fill_in("Title", with: "My Title")
      choose("generic_object_visibility_open")
      click_on "Save"

      click_button "Add to collection"
      select_member_of_collection(persisted_collection)
      click_button "Save changes"

      persisted_object = Hyrax.query_service.find_all_of_model(model: GenericObject).first
      expect(persisted_object.member_of_collection_ids).to eq([persisted_collection.id])
    end
  end
end
