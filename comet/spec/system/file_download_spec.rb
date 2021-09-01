# frozen_string_literal: true

require "rails_helper"

RSpec.describe "FileDownload", type: :system, js: true do
  let(:user) { User.find_or_create_by(email: "comet-admin@library.ucsd.edu") }

  before { sign_in user }
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

    click_on("Save")

    expect(page).to have_content("Test Upload and Download Object")
    object_id = page.current_path.split("/").last
    object = Hyrax.query_service.find_by(id: object_id)
    fileset_id = object.member_ids.first
    visit("/downloads/#{fileset_id}?local=en")
    expect(page).to have_content("abcd")
  end
end
