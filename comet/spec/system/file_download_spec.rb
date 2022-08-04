# frozen_string_literal: true

require "rails_helper"

RSpec.describe "FileDownload", type: :system, storage_adapter: :memory, js: true do
  let(:user) { User.find_or_create_by(email: "comet-admin@library.ucsd.edu") }
  let(:workflow_name) { "surfliner_default" }

  before {
    sign_in user
    setup_workflow_for(user)
  }

  after { sign_out user }

  it "can attach and download and view a file" do
    visit "/dashboard"
    click_on "Objects"
    click_on "add-new-work-button"

    click_link "Files"
    expect(page).to have_content "Add files"
    expect(page).to have_content "Add folder"

    within("div#add-files") do
      attach_file("files[]", Rails.root.join("spec", "fixtures", "image.jpg"), visible: false)
    end

    click_link "Descriptions"
    fill_in("Title", with: "Test Upload and Download Object")
    choose("generic_object_visibility_open")

    # ensure that the form fields are fully populated
    sleep(1.seconds)
    click_on("Save")

    expect(page).to have_content("Test Upload and Download Object")
    expect(page).to have_link("Download", visible: :all)

    find(".attribute-filename").find("a").click
    expect(page).to have_content("File Details")
  end

  context "download file" do
    let(:file) { Rails.root.join("spec", "fixtures", "staging_area", "demo_files", "test.txt") }

    it "show the file content" do
      visit "/dashboard"
      click_on "Objects"
      click_on "add-new-work-button"

      click_link "Files"
      expect(page).to have_content "Add files"
      expect(page).to have_content "Add folder"

      within("div#add-files") do
        attach_file("files[]", file, visible: false)
      end

      click_link "Descriptions"
      fill_in("Title", with: "Test download file object")
      choose("generic_object_visibility_open")

      # ensure that the form fields are fully populated
      sleep(1.seconds)
      click_on("Save")

      expect(page).to have_content("Test download file object")

      find(".attribute.attribute-filename.ensure-wrapped").find("a").click
      expect(page).to have_content("File Details")

      file_set_id = page.current_path.split("/").last
      visit "/downloads/#{file_set_id}?locale=en&inline=true"

      expect(page).to have_content("A dummy text file!")
    end
  end
end
