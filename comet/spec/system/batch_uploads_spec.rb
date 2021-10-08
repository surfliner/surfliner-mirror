# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Collections", type: :system, js: true do
  let(:user) { User.find_or_create_by(email: "comet-admin@library.ucsb.edu") }
  let(:source_file) { Rails.root.join("spec", "fixtures", "batch.csv") }
  let(:s3_enabled_default) { Rails.application.config.staging_area_s3_enabled }

  before do
    Rails.application.config.staging_area_s3_enabled = false
    sign_in user
  end

  after { Rails.application.config.staging_area_s3_enabled = s3_enabled_default }

  it "can see the button for batch ingest and load the form" do
    visit "/dashboard"
    click_on "Batch Uploads"

    expect(page).to have_content("Add New Works by Batch")

    attach_file "Source File", source_file
    fill_in("Files Location", with: "/tmp")
    click_button "Submit"

    expect(page).to have_content("Batch upload submitted successfully.")
  end
end
