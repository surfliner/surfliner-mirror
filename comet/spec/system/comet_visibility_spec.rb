# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Comet Visibility", type: :system, js: true do
  let(:user) { User.find_or_create_by(email: "comet-admin@library.ucsb.edu") }

  before do
    setup_workflow_for(user)
    sign_in user
  end

  after { sign_out user }

  context "object create" do
    let(:file) { Rails.root.join("spec", "fixtures", "staging_area", "demo_files", "test.txt") }

    it "create object in comet visibility" do
      visit "/concern/generic_objects/new#files"
      within("div#add-files") do
        attach_file("files[]", file, visible: false)
      end

      click_link "Descriptions"
      fill_in("Title", with: "Test COMET Visibility Object")
      choose("generic_object_visibility_comet")

      # ensure that the form fields are fully populated
      sleep(2.seconds)
      click_on "Save"

      within("div.title-with-badges") do
        expect(page).to have_content("Test COMET Visibility Object")
        expect(page).to have_css("span.badge.badge-primary", text: "Comet")
      end

      # FileSet visibility
      id = page.current_path.split("/").last
      sleep(1.seconds)
      visit "/concern/generic_objects/#{id}?locale=en"

      expect(page).to have_content("test.txt")
      expect(page).to have_css(".file_set.attributes span.badge.badge-primary", text: "Comet")
    end
  end

  context "object edit" do
    it "with comet visibility selected" do
      visit "/concern/generic_objects/new"

      fill_in("Title", with: "Test COMET Visibility Object")
      choose("generic_object_visibility_comet")

      click_on "Save"

      expect(page).to have_content("Test COMET Visibility Object")

      click_on "Edit"

      within(:css, "ul.visibility") do
        expect(page).to have_checked_field("generic_object_visibility_comet")
      end
    end
  end
end
