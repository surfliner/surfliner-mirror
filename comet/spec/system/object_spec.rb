# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Objects", type: :system, js: true do
  let(:user) { User.find_or_create_by(email: "comet-admin@library.ucsb.edu") }

  before do
    sign_in user
    setup_workflow_for(user)
  end

  it "can list the file sets in a separate tab with counts" do
    visit "/concern/generic_objects/new"
    click_link "Files"
    expect(page).to have_content "Add files"
    expect(page).to have_content "Add folder"

    within("div#add-files") do
      attach_file("files[]", Rails.root.join("spec", "fixtures", "image.jpg"), visible: false)
    end

    click_link "Descriptions"
    fill_in("Title", with: "Test Object")
    choose("generic_object_visibility_open")

    # ensure that the form fields are fully populated
    sleep(2.seconds)
    click_on("Save")

    id = page.current_path.split("/").last
    expect(page).to have_link("Download", visible: :all)

    visit "/concern/generic_objects/#{id}"

    expect(page).to have_content("File Sets (1)")
    expect(page).to have_content("image.jpg")
    expect(page).to have_content("Components (0)")
  end

  it "can list components in a separate tab with counts" do
    visit "/concern/generic_objects/new"

    fill_in("Title", with: "Test Object")
    choose("generic_object_visibility_open")

    # ensure that the form fields are fully populated
    sleep(1.seconds)
    click_on("Save")
    id = page.current_path.split("/").last

    click_button("Add Component")
    click_on("Attach Generic object")

    fill_in("Title", with: "Test Component")
    choose("generic_object_visibility_open")
    sleep(1.seconds)
    click_on("Save")

    visit "/concern/generic_objects/#{id}"
    expect(page).to have_content("Components (1)")
    expect(page).to have_content("File Sets (0)")

    click_on("Components (1)")
    expect(page).to have_link("Test Component")
  end
end
