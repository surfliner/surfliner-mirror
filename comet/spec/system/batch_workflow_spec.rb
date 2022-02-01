# frozen_string_literal: true

require "rails_helper"

RSpec.describe "BatchUploads", type: :system, js: true do
  let(:user) { User.find_or_create_by(email: "comet-admin@library.ucsb.edu") }
  let(:source_file) { Rails.root.join("spec", "fixtures", "batch.csv") }
  let(:s3_enabled_default) { Rails.application.config.staging_area_s3_enabled }

  let(:approving_user) { User.find_or_create_by(email: "comet-admin@library.ucsb.edu") }

  before do
    setup_workflow_for(user)
    sign_in user
  end

  after { Rails.application.config.staging_area_s3_enabled = s3_enabled_default }

  context "move batch of objects through workflow" do
    let(:file) { Rails.root.join("spec", "fixtures", "image.jpg") }
    let(:s3_key) { "my-project/image.jpg" }
    let(:s3_bucket) { ENV.fetch("STAGING_AREA_S3_BUCKET", "comet-staging-area-#{Rails.env}") }

    before do
      Rails.application.config.staging_area_s3_enabled = true
      staging_area_upload(fog_connection: Rails.application.config.staging_area_s3_connection,
        bucket: s3_bucket, s3_key: s3_key, source_file: file)
    end

    it "review submissions by batch" do
      visit "/dashboard"
      click_on "Batch Uploads"

      expect(page).to have_content("Add New Works by Batch")

      attach_file "Source File", source_file
      select_s3_path("my-project/")

      click_button "Submit"

      expect(page).to have_content("Successfully ingest objects in batch.")

      click_on "Review Submissions"

      expect(page).to have_content("in_review")

      click_button "Batch Review"
      expect(page).to have_content("Batch Workflow Actions")

      choose(option: "request_changes")
      fill_in("workflow_action_comment", with: "Typos in title.")
      click_button "Submit"

      expect(page).to have_content("Batch workflow updated successfully.")
      expect(page).to have_content("changes_required")
    end

    it "refined by batch ID for batch review" do
      visit "/dashboard"
      click_on "Batch Uploads"

      expect(page).to have_content("Add New Works by Batch")

      attach_file "Source File", source_file
      select_s3_path("my-project/")

      click_button "Submit"

      expect(page).to have_content("Successfully ingest objects in batch.")

      click_on "Review Submissions"

      expect(page).to have_selector("h1", text: "Review Submissions")

      click_link "Refined By Batch"

      expect(page).to have_content("Batch ID")

      first(".batch_upload_row").click

      expect(page).to have_content("Batch ingest object")

      click_button "Batch Review"
      expect(page).to have_content("Batch Workflow Actions")

      choose(option: "request_changes")
      fill_in("workflow_action_comment", with: "Comments")
      click_button "Submit"

      expect(page).to have_content("Batch workflow updated successfully.")
      expect(page).to have_content("changes_required")
    end
  end
end
