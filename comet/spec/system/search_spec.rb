# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Search", type: :system, js: true do
  let(:user) { User.find_or_create_by(email: "comet-admin@library.ucsb.edu") }

  before { sign_in(user) }

  it "returns search results" do
    visit "/"
    expect(page).to have_content("Search Comet")
  end

  context "search objects" do
    before do
      setup_workflow_for(user)
    end

    it "performing a search" do
      visit "/concern/generic_objects/new"
      fill_in("Title", with: "Test Object")
      choose("generic_object_visibility_open")

      click_on("Save")

      id = page.current_path.split("/").last
      obj = Hyrax.query_service.find_by(id: id)
      obj.ark = "ark:/99999/fk4test"
      Hyrax.persister.save(resource: obj)
      Hyrax.index_adapter.save(resource: obj)

      visit "/concern/generic_objects/#{id}?locale=en"

      click_on "Review and Approval"
      choose("Approve")
      click_on("Submit")

      visit "/"
      within("#search-form-header") do
        fill_in("search-field-header", with: "Test")
        click_button("Go")
      end

      expect(page).to have_content("Search Results")
      expect(page).to have_content("Test Object")
    end
  end

  context "with collections" do
    let(:collection_type) { Hyrax::CollectionType.create(title: "Test Type") }
    let(:collection_type_gid) { collection_type.to_global_id.to_s }

    let(:collection) do
      col = Hyrax::PcdmCollection.new(title: ["Test Collection"], collection_type_gid: collection_type_gid)
      Hyrax.persister.save(resource: col)
    end

    before { Hyrax.index_adapter.save(resource: collection) }

    it "performing a searc" do
      visit "/"
      within("#search-form-header") do
        fill_in("search-field-header", with: "Test")
        click_button("Go")
      end

      expect(page).to have_content("Search Results")
      expect(page).to have_content("Test Collection")
    end
  end
end
