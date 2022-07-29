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

  context "with local staging" do
    let(:files_location) { Rails.root.join("spec", "fixtures") }

    before { Rails.application.config.staging_area_s3_enabled = false }

    context "with source files in staging area" do
      it "can load the form and ingest the object with file" do
        visit "/dashboard"
        click_on "Batch Uploads"

        expect(page).to have_content("Add New Works by Batch")

        attach_file "Source File", source_file
        # see: https://stackoverflow.com/questions/70441796/selenium-webdriver-for-aws-device-farm-error-when-sending-period-keystroke-t/70443309#70443309
        Capybara.current_session.driver.browser.file_detector = nil
        fill_in("Files Location", with: files_location)
        click_button "Submit"

        expect(page).to have_content("Successfully ingest objects in batch.")

        find("#documents").first(:link, "Batch ingest object").click
        expect(page).to have_link("Review and Approval")
        expect(page).to have_link("image.jpg")

        click_on "image.jpg"

        expect(page).to have_link("Download the file")
      end
    end

    context "with ingest option" do
      let(:files_location) { Rails.root.join("spec", "fixtures", "batch_files") }

      it "loads the files-only ingest form" do
        visit "/dashboard"
        click_on "Batch Uploads"

        expect(page).to have_content("Add New Works by Batch")

        select "files-only", from: "batch_upload_option"

        expect(page).to have_select("batch_upload_option", selected: "files-only")

        # see: https://stackoverflow.com/questions/70441796/selenium-webdriver-for-aws-device-farm-error-when-sending-period-keystroke-t/70443309#70443309
        Capybara.current_session.driver.browser.file_detector = nil
        fill_in("Files Location", with: files_location)
        click_button "Submit"

        expect(page).to have_content("Successfully ingest objects in batch.")

        find("#documents").first(:link, "image.jpg").click
        expect(page).to have_link("Review and Approval")
        expect(page).to have_link("image.jpg")

        click_on "image.jpg"

        expect(page).to have_link("Download the file")
      end
    end

    context "with files missing from staging area" do
      let(:other_files_location) { Rails.root.join("spec", "fixtures", "staging_area", "demo_data") }

      it "can see the button for batch ingest and load the form" do
        visit "/dashboard"
        click_on "Batch Uploads"

        expect(page).to have_content("Add New Works by Batch")

        attach_file "Source File", source_file
        # see: https://stackoverflow.com/questions/70441796/selenium-webdriver-for-aws-device-farm-error-when-sending-period-keystroke-t/70443309#70443309
        Capybara.current_session.driver.browser.file_detector = nil
        fill_in("Files Location", with: other_files_location)
        click_button "Submit"

        expect(page.current_path).to eq("/batch_uploads/new")
        expect(page).to have_content("Error missing staging area file: image.jpg.")
      end
    end
  end

  context "with S3/Minio staging enabled" do
    let(:file) { Rails.root.join("spec", "fixtures", "image.jpg") }
    let(:s3_key) { "my-project/image.jpg" }
    let(:s3_bucket) { ENV.fetch("STAGING_AREA_S3_BUCKET", "comet-staging-area-#{Rails.env}") }

    before do
      Rails.application.config.staging_area_s3_enabled = true
    end

    context "with source files in staging area" do
      before do
        staging_area_upload(fog_connection: Rails.application.config.staging_area_s3_connection,
          bucket: s3_bucket, s3_key: s3_key, source_file: file)
      end

      it "can see the button for batch ingest and load the form" do
        visit "/dashboard"
        click_on "Batch Uploads"

        expect(page).to have_content("Add New Works by Batch")

        attach_file "Source File", source_file
        select_s3_path("my-project/")

        click_button "Submit"

        expect(page).to have_content("Successfully ingest objects in batch.")
        expect(page).to have_content("Batch ingest object")

        find("#documents").first(:link, "Batch ingest object").click
        expect(page).to have_link("Review and Approval")
        expect(page).to have_link("image.jpg")

        click_on "image.jpg"

        expect(page).to have_link("Download the file")
      end
    end

    context "with ingest option" do
      it "loads the files-only ingest form" do
        visit "/dashboard"
        click_on "Batch Uploads"

        expect(page).to have_content("Add New Works by Batch")

        select "files-only", from: "batch_upload_option"

        expect(page).to have_select("batch_upload_option", selected: "files-only")

        select_s3_path("my-project/")

        click_button "Submit"

        expect(page).to have_content("Successfully ingest objects in batch.")

        find("#documents").first(:link, "image.jpg").click
        expect(page).to have_link("Review and Approval")
        expect(page).to have_link("image.jpg")

        click_on "image.jpg"

        expect(page).to have_link("Download the file")
      end
    end

    context "with files missing from staging area" do
      let(:other_file) { Rails.root.join("spec", "fixtures", "upload.txt") }
      let(:other_s3_key) { "my-other-project/upload.txt" }

      before do
        staging_area_upload(fog_connection: Rails.application.config.staging_area_s3_connection,
          bucket: s3_bucket, s3_key: other_s3_key, source_file: other_file)
      end

      it "can see the button for batch ingest and load the form" do
        visit "/dashboard"
        click_on "Batch Uploads"

        expect(page).to have_content("Add New Works by Batch")

        attach_file "Source File", source_file
        select_s3_path("my-other-project/")

        click_button "Submit"

        expect(page.current_path).to eq("/batch_uploads/new")
        expect(page).to have_content("Error missing staging area file: image.jpg.")
      end
    end
  end

  context "with invalid CSV source" do
    let(:invalid_source_file) { Rails.root.join("spec", "fixtures", "batch_invalid.csv") }

    before { Rails.application.config.staging_area_s3_enabled = false }

    it "has invalid headers message for batch ingest" do
      visit "/dashboard"
      click_on "Batch Uploads"

      expect(page).to have_content("Add New Works by Batch")

      attach_file "Source File", invalid_source_file
      # see: https://stackoverflow.com/questions/70441796/selenium-webdriver-for-aws-device-farm-error-when-sending-period-keystroke-t/70443309#70443309
      Capybara.current_session.driver.browser.file_detector = nil
      fill_in("Files Location", with: "/tmp")
      click_button "Submit"

      expect(page).to have_content("Validation failed! Invalid headers: invalid header.")
    end
  end
end
