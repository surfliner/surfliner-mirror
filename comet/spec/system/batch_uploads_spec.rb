# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Collections", type: :system, js: true do
  let(:user) { User.find_or_create_by(email: "comet-admin@library.ucsb.edu") }
  let(:source_file) { Rails.root.join("spec", "fixtures", "batch.csv") }
  let(:s3_enabled_default) { Rails.application.config.staging_area_s3_enabled }

  before { sign_in user }

  after { Rails.application.config.staging_area_s3_enabled = s3_enabled_default }

  context "with local staging" do
    before { Rails.application.config.staging_area_s3_enabled = false }

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

  context "with S3/Minio staging enabled" do
    let(:file) { Tempfile.new("image.jpg").tap { |f| f.write("A fade image!") } }
    let(:s3_key) { "my-project/image.jpg" }
    let(:s3_bucket) { ENV.fetch("STAGING_AREA_S3_BUCKET", "comet-staging-area-#{Rails.env}") }

    before do
      Rails.application.config.staging_area_s3_enabled = true
      staging_area_upload(bucket: s3_bucket, s3_key: s3_key, source_file: file)
    end

    it "can see the button for batch ingest and load the form" do
      visit "/dashboard"
      click_on "Batch Uploads"

      expect(page).to have_content("Add New Works by Batch")

      attach_file "Source File", source_file
      select_s3_path("my-project/")

      click_button "Submit"

      expect(page).to have_content("Batch upload submitted successfully.")
    end
  end
end
