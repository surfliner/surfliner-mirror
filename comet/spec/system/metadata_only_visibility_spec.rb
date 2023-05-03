# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Metadata-only Visibility", type: :system, js: true do
  let(:user) { User.find_or_create_by(email: "comet-admin@library.ucsb.edu") }

  before do
    setup_workflow_for(user)
    sign_in user
  end

  after { sign_out user }

  context "object create" do
    let(:file) { Rails.root.join("spec", "fixtures", "staging_area", "demo_files", "test.txt") }

    it "create object with metadata-only visibility" do
      visit "/concern/generic_objects/new#files"
      within("div#add-files") do
        attach_file("files[]", file, visible: false)
      end

      click_link "Descriptions"
      fill_in("Title", with: "Test METADATA-ONLY Visibility Object")
      choose("generic_object_visibility_metadata_only")

      # ensure that the form fields are fully populated
      sleep(2.seconds)
      click_on "Save"

      within("div.title-with-badges") do
        expect(page).to have_content("Test METADATA-ONLY Visibility Object")
        expect(page).to have_css("span.label.label-warning", text: "Metadata-only")
      end

      # FileSet with Private visibility
      id = page.current_path.split("/").last
      sleep(2.seconds)
      visit "/concern/generic_objects/#{id}?locale=en"

      expect(page).to have_content("test.txt")
      expect(page).to have_css(".file_set.attributes span.label.label-danger", text: "Private")
    end
  end

  context "object edit" do
    let(:file) { Rails.root.join("spec", "fixtures", "upload.txt") }

    it "auto selected with Metadata-only visibility" do
      visit "/concern/generic_objects/new"

      fill_in("Title", with: "Test METADATA-ONLY Visibility Object")
      choose("generic_object_visibility_metadata_only")

      click_on "Save"

      expect(page).to have_content("Test METADATA-ONLY Visibility Object")

      click_on "Edit"

      within(:css, "ul.visibility") do
        expect(page).to have_checked_field("generic_object_visibility_metadata_only")
      end
    end

    it "can update to Comet visibility" do
      visit "/concern/generic_objects/new#files"
      within("div#add-files") do
        attach_file("files[]", file, visible: false)
      end

      click_link "Descriptions"
      fill_in("Title", with: "Test METADATA-ONLY Visibility Object")
      choose("generic_object_visibility_metadata_only")

      # ensure that the form fields are fully populated
      sleep(2.seconds)
      click_on "Save"

      id = page.current_path.split("/").last

      within("div.title-with-badges") do
        expect(page).to have_content("Test METADATA-ONLY Visibility Object")
        expect(page).to have_css("span.label.label-warning", text: "Metadata-only")
      end

      # FileSet with Private visibility
      sleep(2.seconds)
      visit "/concern/generic_objects/#{id}?locale=en"

      expect(page).to have_content("upload.txt")
      expect(page).to have_css(".file_set.attributes span.label.label-danger", text: "Private")

      click_on "Edit"

      fill_in("Title", with: "Test METADATA-ONLY Visibility Object - Updated to Comet Visibility")
      within(:css, "ul.visibility") do
        expect(page).to have_checked_field("generic_object_visibility_metadata_only")

        choose("generic_object_visibility_comet")
      end

      click_on "Save changes"

      click_on "Yes please."

      # Visibility is changed to Comet
      within("div.title-with-badges") do
        expect(page).to have_content("Test METADATA-ONLY Visibility Object - Updated to Comet Visibility")
        expect(page).to have_css("span.label.label-primary", text: "Comet")
      end
    end

    it "can update to Public visibility" do
      visit "/concern/generic_objects/new?locale=en"

      fill_in("Title", with: "Test Object - METADATA-ONLY Visibility")
      choose("generic_object_visibility_metadata_only")

      # ensure that the form fields are fully populated
      sleep(1.seconds)
      click_on "Save"

      within("div.title-with-badges") do
        expect(page).to have_content("Test Object - METADATA-ONLY Visibility")
        expect(page).to have_css("span.label.label-warning", text: "Metadata-only")
      end

      click_on "Edit"

      fill_in("Title", with: "Test Object - METADATA-ONLY to PUBLIC Visibility")
      within(:css, "ul.visibility") do
        expect(page).to have_checked_field("generic_object_visibility_metadata_only")

        choose("generic_object_visibility_open")
      end

      click_on "Save changes"

      # Visibility is changed to Comet
      within("div.title-with-badges") do
        expect(page).to have_content("Test Object - METADATA-ONLY to PUBLIC Visibility")
        expect(page).to have_css("span.label.label-success", text: "Public")
      end
    end
  end
end
