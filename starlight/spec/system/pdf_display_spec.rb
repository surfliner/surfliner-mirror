# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Display embedded PDFs", :clean, type: :system, js: true do
  let(:site_admin) { FactoryBot.create(:omniauth_site_admin) }

  before do
    omniauth_setup_dev_auth_for(site_admin)
    sign_in
    allow(Spotlight::DefaultThumbnailJob).to receive(:perform_later)
    allow_any_instance_of(CarrierWave::Downloader::Base).to receive(:skip_ssrf_protection?).and_return(true)
    visit "/"
    click_link site_admin.user_key
    click_link "Create new exhibit"
    fill_in("Title", with: "Test Exhibit")
    fill_in("Tag list", with: "testing")
    click_button "Create Exhibit"
    visit "/starlight/test-exhibit/edit"
    page.check("exhibit_published")
    click_button "Save changes"

    visit("/starlight/test-exhibit/resources/new")
    click_link "Upload item"
    page.attach_file("resources_upload[url]", File.join(fixture_path, "blank.pdf"))
    fill_in("Title", with: "PDF")
    within "#new_resources_upload" do
      click_button "Add item"
    end
  end

  context "when viewing a PDF" do
    it "uses a direct embed" do
      visit "/starlight/test-exhibit/catalog?utf8=%E2%9C%93&exhibit_id=test-exhibit&search_field=all_fields&q="
      expect(page).to have_content "PDF"

      click_link "PDF"

      expect(page).to have_selector "embed"
      expect(page).not_to have_selector ".universal-viewer-iframe"
    end
  end
end
