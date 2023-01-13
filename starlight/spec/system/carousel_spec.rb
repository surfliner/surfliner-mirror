# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Solr Documents Carousel Block", :clean, type: :system, js: true do
  let(:image_upload_file_path) { File.join(fixture_path, "/images/colima-dog.jpg") }
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

    # Upload image for carousel
    visit("/starlight/test-exhibit/resources/new")
    click_link "Upload item"
    page.attach_file("resources_upload[url]", image_upload_file_path)
    fill_in("Title", with: "Colima")
    within "#new_resources_upload" do
      click_button "Add item"
    end

    # Setup Carousel widget block
    visit("/starlight/test-exhibit/home/edit")
    add_widget "solr_documents_carousel"
  end

  it "allows a curator to select a caption to display" do
    fill_in_typeahead_field with: "Colima"

    check "Primary caption"
    select "Title", from: "primary-caption-field"

    save_widget_block

    within ".carousel-block" do
      expect(page).to have_css(".carousel-item", count: 1)
      expect(page).to have_css(".carousel-caption .primary", text: "Colima")
    end
  end
end
