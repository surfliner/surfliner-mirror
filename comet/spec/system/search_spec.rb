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

    it "performing a search across configured M3 fields" do
      visit "/concern/generic_objects/new"
      fill_in("Title", with: "Test Search Object 1")
      click_on "Additional fields"
      fill_in("Alternative title", with: "moomin")

      choose("generic_object_visibility_open")

      click_on("Save")

      id = page.current_path.split("/").last
      obj = Hyrax.query_service.find_by(id: id)
      obj.ark = "ark:/99999/fk5test"
      Hyrax.persister.save(resource: obj)
      Hyrax.index_adapter.save(resource: obj)

      visit "/concern/generic_objects/#{obj.id}?locale=en"
      click_on "Review and Approval"
      choose("Approve")
      click_on("Submit")

      visit "/concern/generic_objects/new"
      fill_in("Title", with: "Test Search Object 2")
      click_on "Additional fields"
      fill_in("Description", with: "moomin")

      choose("generic_object_visibility_open")

      click_on("Save")

      id = page.current_path.split("/").last
      obj = Hyrax.query_service.find_by(id: id)
      obj.ark = "ark:/99999/fk6test"
      Hyrax.persister.save(resource: obj)
      Hyrax.index_adapter.save(resource: obj)

      visit "/concern/generic_objects/#{obj.id}?locale=en"
      click_on "Review and Approval"
      choose("Approve")
      click_on("Submit")

      visit "/"
      within("#search-form-header") do
        fill_in("search-field-header", with: "moomin")
        click_button("Go")
      end

      expect(page).to have_content("Search Results")
      expect(page).to have_content("Test Search Object 1")
      expect(page).to have_content("Test Search Object 2")
    end

    it "performing a search for creator LastName, Firstname without using double quotes around them" do
      visit "/concern/generic_objects/new"
      fill_in("Title", with: "Test Search Creator")
      click_on "Additional fields"
      fill_in("Creator", with: "LastName, FirstName")

      choose("generic_object_visibility_open")

      click_on("Save")

      id = page.current_path.split("/").last
      obj = Hyrax.query_service.find_by(id: id)
      obj.ark = "ark:/99999/fk7test"
      Hyrax.persister.save(resource: obj)
      Hyrax.index_adapter.save(resource: obj)

      visit "/concern/generic_objects/#{obj.id}?locale=en"
      click_on "Review and Approval"
      choose("Approve")
      click_on("Submit")

      visit "/"
      within("#search-form-header") do
        fill_in("search-field-header", with: "LastName, Firstname")
        click_button("Go")
      end

      expect(page).to have_content("Search Results")
      expect(page).to have_content("Test Search Creator")
      expect(page).to have_content("LastName, Firstname")
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
