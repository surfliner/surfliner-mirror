# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Import and Display a Work", :clean, type: :system, js: true do
  let(:csv_file_path) { File.join(fixture_path, csv_file_name) }
  let(:csv_file_name) { "file_single_item_exhibit.csv" }
  let(:site_admin) { FactoryBot.create(:omniauth_site_admin) }

  before do
    omniauth_setup_dev_auth_for(site_admin)
    sign_in
    allow(Spotlight::DefaultThumbnailJob).to receive(:perform_later)
    allow_any_instance_of(CarrierWave::Downloader::Base).to receive(:skip_ssrf_protection?).and_return(true)
  end

  context "Create an exhibit" do
    it "creates and populates an exhibit via the UI" do
      expect(Spotlight::Exhibit.count).to eq 0
      visit "/"
      click_link site_admin.user_key
      click_link "Create new exhibit"
      fill_in("Title", with: "Test Exhibit")
      fill_in("Tag list", with: "testing")
      click_button "Create Exhibit"
      expect(page).to have_content "The exhibit was created."
      visit "/starlight/test-exhibit/edit"
      page.check("exhibit_published")
      click_button "Save changes"
      expect(Spotlight::Exhibit.count).to eq 1
      expect(Spotlight::Exhibit.first.published).to be true
      visit("/starlight/test-exhibit/resources/new")
      stubbed_upload = stub_http_image_uploads
      click_link "Upload multiple items"
      expect(page).to have_content "CSV file"
      page.attach_file("resources_csv_upload[url]", csv_file_path)
      within "#new_resources_csv_upload" do
        click_button "Add item"
      end
      expect(stubbed_upload).to have_been_requested
      visit "/starlight/test-exhibit/catalog?utf8=%E2%9C%93&exhibit_id=test-exhibit&search_field=all_fields&q="
      expect(page).to have_content "Colima dog in Santa Rosilia"

      # Test that the exhibit page is accessible to non-admin users
      sign_out
      visit "/starlight/test-exhibit/catalog?utf8=%E2%9C%93&exhibit_id=test-exhibit&search_field=all_fields&q="
      expect(page).to have_content "Colima dog in Santa Rosilia"

      click_link "Colima dog in Santa Rosilia"
      # IIIF Manifest present on the page
      expect(page.html).to match(%r{/starlight/.*/manifest})
      expect(page).to have_selector ".universal-viewer-iframe"
    end
  end
end
