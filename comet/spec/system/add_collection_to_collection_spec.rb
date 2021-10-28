# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Collections", type: :system, js: true, storage_adapter: :memory, metadata_adapter: :test_adapter do
  let(:user) { User.find_or_create_by(email: "comet-admin@library.ucsb.edu") }
  before { sign_in user }

  it "can create a new collection and add subcollection" do
    visit "/admin/collection_types"
    click_on "Create new collection type"
    fill_in("Type name", with: "Curated Collection")
    click_on "Save"

    visit "/dashboard"
    click_on "Collections"
      expect(page).to have_link("New Collection")
    
      click_on "New Collection"
      fill_in("Title", with: "Parent Collection")

      click_on("Save")

      visit "/dashboard"
      click_on "Collections"
      expect(page).to have_link("New Collection")

      click_on "New Collection"
      fill_in("Title", with: "Child Collection")

      click_on("Save")

      expect(page).to have_content("Collection was successfully created.")
      expect(page).to have_content("Parent Collection")
      expect(page).to have_content("Child Collection")

      persisted_collections = Hyrax.query_service.find_all_of_model(model: Hyrax::PcdmCollection)
      parent_collection = persisted_collections.find do |col|
        col.title == ["Parent Collection"]
      end
 
      child_collection = persisted_collections.find do |col|
        col.title == ["Child Collection"]
      end
            
      visit "/dashboard/collections/#{parent_collection.id.to_s}?locale=en"
      expect(page).to have_content("Parent Collection")
      click_on "Create new collection as subcollection"
      
      
      #click_on "Add a subcollection"    
      #find("#add-subcollection-modal-#{child_collection.id.to_s}").click
      #puts page.body       
      #find(".child_id option[value='#{child_collection.id.to_s}']").select_option
      #select("#{child_collection.id.to_s}", from: "child_id").select_option
      #click_on "Add a subcollection" 
      #expect(page).to have_content("Child Collection")
                
      
  end

end
