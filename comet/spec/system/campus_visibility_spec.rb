# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Campus Visibility", type: :system, js: true do
  let(:user) { User.find_or_create_by(email: "comet-admin@library.ucsb.edu") }

  before do
    setup_workflow_for(user)
    sign_in user
  end

  after { sign_out user }

  context "new object" do
    let(:file) { Rails.root.join("spec", "fixtures", "staging_area", "demo_files", "test.txt") }

    it "create object in campus visibility" do
      visit "/concern/generic_objects/new#files"
      within("div#add-files") do
        attach_file("files[]", file, visible: false)
      end

      click_link "Descriptions"
      fill_in("Title", with: "Test CAMPUS Visibility Object")
      choose("generic_object_visibility_campus")

      # ensure that the form fields are fully populated
      sleep(2.seconds)
      click_on "Save"

      within("div.title-with-badges") do
        expect(page).to have_content("Test CAMPUS Visibility Object")
        expect(page).to have_css("span.label.label-info", text: "Campus")
      end

      # FileSet visibility
      id = page.current_path.split("/").last
      sleep(1.seconds)
      visit "/concern/generic_objects/#{id}?locale=en"

      expect(page).to have_content("test.txt")
      expect(page).to have_css(".file_set.attributes span.label.label-info", text: "Campus")
    end
  end

  context "edit object" do
    it "with campus visibility selected" do
      visit "/concern/generic_objects/new"

      fill_in("Title", with: "Test CAMPUS Visibility Object")
      choose("generic_object_visibility_campus")

      click_on "Save"

      expect(page).to have_content("Test CAMPUS Visibility Object")

      click_on "Edit"

      within(:css, "ul.visibility") do
        expect(page).to have_checked_field("generic_object_visibility_campus")
      end
    end
  end
end
