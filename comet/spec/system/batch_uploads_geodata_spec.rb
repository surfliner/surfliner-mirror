# frozen_string_literal: true

require "rails_helper"

RSpec.describe "BatchUploadsGeodata", type: :system, js: true do
  let(:user) { User.find_or_create_by(email: "comet-admin@library.ucsb.edu") }
  let(:source_file) { Rails.root.join("spec", "fixtures", "gford-geodata-test.csv") }
  let(:s3_enabled_default) { Rails.application.config.staging_area_s3_enabled }

  let(:approving_user) { User.find_or_create_by(email: "comet-admin@library.ucsb.edu") }

  before do
    setup_workflow_for(user)
    sign_in user
  end

  after { Rails.application.config.staging_area_s3_enabled = s3_enabled_default }

  context "with local staging" do
    let(:files_location) { Rails.root.join("spec", "fixtures", "geodata", "shapefiles", "gford-20140000-010002_lakes") }

    before { Rails.application.config.staging_area_s3_enabled = false }

    context "with source files in staging area" do
      it "can load the form and ingest the object with file" do
        visit "/dashboard"
        click_on "Batch Uploads"

        expect(page).to have_content("Add New Works by Batch")

        select "geodata", from: "batch_upload_option"
        expect(page).to have_select("batch_upload_option", selected: "geodata")

        attach_file "Source File", source_file
        # see: https://stackoverflow.com/questions/70441796/selenium-webdriver-for-aws-device-farm-error-when-sending-period-keystroke-t/70443309#70443309
        Capybara.current_session.driver.browser.file_detector = nil
        fill_in("Files Location", with: files_location)
        click_button "Submit"

        expect(page).to have_content("Successfully ingest objects in batch.")

        find("#documents").first(:link, "Lakes, Maya Forest, Guatemala, 2000").click
        expect(page).to have_link("Review and Approval")
        expect(page).to have_link("gford-20140000-010002_lakes-a.shp")

        click_on "gford-20140000-010002_lakes-a.shp"

        expect(page).to have_link("Download the file")

        file_set_id = page.current_path.split("/").last
        file_set = Hyrax.query_service.find_by(id: file_set_id)

        expect(file_set.file_ids.length).to eq(7)

        results = Hyrax.query_service.find_all_of_model(model: Hyrax::FileMetadata)

        expected_files = results.select { |fm| file_set.file_ids.map { |fid| fid.to_s }.include?(fm.file_identifier.to_s) }
        expect(expected_files.length).to eq(7)

        primary_file = results.find { |fm| fm.file_identifier.to_s == file_set.file_ids.first }
        expect(primary_file.label).to eq(["gford-20140000-010002_lakes-a.shp"])
        expect(primary_file.type.first.to_s).to eq("http://pcdm.org/use#GeoShapeFile")
        expect(primary_file.file_set_id.to_s).to eq(file_set.id.to_s)
      end
    end

    context "with files missing from staging area" do
      let(:other_files_location) { Rails.root.join("spec", "fixtures", "staging_area", "demo_data") }

      it "can see the button for batch ingest and load the form" do
        visit "/dashboard"
        click_on "Batch Uploads"

        expect(page).to have_content("Add New Works by Batch")

        select "geodata", from: "batch_upload_option"
        expect(page).to have_select("batch_upload_option", selected: "geodata")

        attach_file "Source File", source_file
        # see: https://stackoverflow.com/questions/70441796/selenium-webdriver-for-aws-device-farm-error-when-sending-period-keystroke-t/70443309#70443309
        Capybara.current_session.driver.browser.file_detector = nil
        fill_in("Files Location", with: other_files_location)
        click_button "Submit"

        expect(page.current_path).to eq("/batch_uploads/new")
        expect(page).to have_content("Error missing staging area file: gford-20140000-010002_lakes-a.")
      end
    end
  end

  context "with S3/Minio staging enabled" do
    let(:files_location) { Rails.root.join("spec", "fixtures", "geodata", "shapefiles", "gford-20140000-010002_lakes") }
    let(:s3_key_prefix) { "my-geoproject/" }
    let(:s3_bucket) { ENV.fetch("STAGING_AREA_S3_BUCKET", "comet-staging-area-#{Rails.env}") }

    before do
      Rails.application.config.staging_area_s3_enabled = true
    end

    context "with source files in staging area" do
      before do
        Dir.entries(files_location).each do |f|
          if File.file?("#{files_location}/#{f}")
            staging_area_upload(fog_connection: Rails.application.config.staging_area_s3_connection,
              bucket: s3_bucket, s3_key: "#{s3_key_prefix}#{f}", source_file: "#{files_location}/#{f}")
          end
        end
      end

      it "can see the button for batch ingest and load the form" do
        visit "/dashboard"
        click_on "Batch Uploads"

        expect(page).to have_content("Add New Works by Batch")

        select "geodata", from: "batch_upload_option"
        expect(page).to have_select("batch_upload_option", selected: "geodata")

        attach_file "Source File", source_file
        select_s3_path(s3_key_prefix)

        click_button "Submit"

        expect(page).to have_content("Successfully ingest objects in batch.")
        expect(page).to have_content("Lakes, Maya Forest, Guatemala, 2000")

        find("#documents").first(:link, "Lakes, Maya Forest, Guatemala, 2000").click
        expect(page).to have_link("Review and Approval")
        expect(page).to have_link("gford-20140000-010002_lakes-a.shp")

        click_on "gford-20140000-010002_lakes-a.shp"

        expect(page).to have_link("Download the file")

        file_set_id = page.current_path.split("/").last
        file_set = Hyrax.query_service.find_by(id: file_set_id)

        expect(file_set.file_ids.length).to eq(7)

        results = Hyrax.query_service.find_all_of_model(model: Hyrax::FileMetadata)

        expected_files = results.select { |fm| file_set.file_ids.map { |fid| fid.to_s }.include?(fm.file_identifier.to_s) }
        expect(expected_files.length).to eq(7)

        primary_file = results.find { |fm| fm.file_identifier.to_s == file_set.file_ids.first }
        expect(primary_file.label).to eq(["gford-20140000-010002_lakes-a.shp"])
        expect(primary_file.type.first.to_s).to eq("http://pcdm.org/use#GeoShapeFile")
        expect(primary_file.file_set_id.to_s).to eq(file_set.id.to_s)
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

        select "geodata", from: "batch_upload_option"
        expect(page).to have_select("batch_upload_option", selected: "geodata")

        attach_file "Source File", source_file
        select_s3_path("my-other-project/")

        click_button "Submit"

        expect(page.current_path).to eq("/batch_uploads/new")
        expect(page).to have_content("Error missing staging area file: gford-20140000-010002_lakes-a.")
      end
    end
  end
end
