# frozen_string_literal: true

require "rails_helper"

RSpec.describe "FileVisibilityPropagation", type: :system, storage_adapter: :memory, js: true do
  include ActiveJob::TestHelper

  let(:user) { User.find_or_create_by(email: "comet-admin@library.ucsd.edu") }
  let(:workflow_name) { "surfliner_default" }
  let(:file) { Rails.root.join("spec", "fixtures", "staging_area", "demo_files", "test.txt") }

  before {
    sign_in user
    setup_workflow_for(user)
  }

  after { sign_out user }

  it "creates file with visibility of the parent fileset" do
    # upload the file
    visit "/concern/generic_objects/new#files"
    within("div#add-files") do
      attach_file("files[]", file, visible: false)
    end

    # set up the object metadata
    click_link "Descriptions"
    fill_in("Title", with: "Test File Visibility")
    choose("generic_object_visibility_open")

    # ensure that the form fields are fully populated
    sleep(1.seconds)
    click_on("Save")

    # wait for new page to load
    expect(page).to have_xpath("//a[normalize-space(.)='test.txt']")

    # get the file set via valkyrie
    file_set_link = find(:xpath, "//a[normalize-space(.)='test.txt']")
    file_set_id = %r{file_sets/([^/?]+)}.match(file_set_link[:href])[1]
    file_set = Hyrax.query_service.find_by(id: Valkyrie::ID.new(file_set_id))

    # test the file visibility
    file = Hyrax.query_service.custom_queries.find_files(file_set: file_set).first
    expect(file.visibility).to eq Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
  end

  it "propagates visibility changes to the file on request" do
    # upload the file
    visit "/concern/generic_objects/new#files"
    within("div#add-files") do
      attach_file("files[]", file, visible: false)
    end

    # set up the object metadata
    click_link "Descriptions"
    fill_in("Title", with: "Test File Visibility")
    choose("generic_object_visibility_open")

    # ensure that the form fields are fully populated
    sleep(1.seconds)
    click_on("Save")

    # wait for new page to load
    expect(page).to have_xpath("//a[normalize-space(.)='test.txt']")

    # get the file set via valkyrie
    file_set_link = find(:xpath, "//a[normalize-space(.)='test.txt']")
    file_set_id = %r{file_sets/([^/?]+)}.match(file_set_link[:href])[1]
    file_set = Hyrax.query_service.find_by(id: Valkyrie::ID.new(file_set_id))

    # test the file visibility
    file = Hyrax.query_service.custom_queries.find_files(file_set: file_set).first
    expect(file.visibility).to eq Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC

    # propagate a visibility change
    perform_enqueued_jobs do
      click_on("Edit")
      choose("generic_object_visibility_restricted")
      click_on("Save")
      expect(page).to have_content("Apply changes to contents?")
      click_on("Yes please.")
    end

    # test the file visibility (again)
    file = Hyrax.query_service.custom_queries.find_files(file_set: file_set).first
    expect(file.visibility).to eq Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
  end
end
