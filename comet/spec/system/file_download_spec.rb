# frozen_string_literal: true

require "rails_helper"

RSpec.describe "FileDownload", type: :system, storage_adapter: :memory, metadata_adapter: :test_adapter, js: true do
  let(:user) { User.find_or_create_by(email: "comet-admin@library.ucsd.edu") }
  let(:workflow_name) { "surfliner_default" }

  before {
    sign_in user
    setup_workflow_for(user)
  }

  after { sign_out user }

  it "can attach and download a file" do
    visit "/dashboard"
    click_on "Works"
    click_on "Add new work"

    click_link "Files"
    expect(page).to have_content "Add files"
    expect(page).to have_content "Add folder"

    within("div#add-files") do
      attach_file("files[]", Rails.root.join("spec", "fixtures", "upload.txt"), visible: false)
    end

    click_link "Descriptions"
    fill_in("Title", with: "Test Upload and Download Object")
    choose("generic_object_visibility_open")

    # ensure that the form fields are fully populated
    sleep(1.seconds)
    click_on("Save")

    expect(page).to have_content("Test Upload and Download Object")
    expect(page).to have_link("Download", visible: :all)
  end
end
