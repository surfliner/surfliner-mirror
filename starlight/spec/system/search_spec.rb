# frozen_string_literal: true

require "rails_helper"

# These fields should be searchable per https://help.library.ucsb.edu/browse/DIGREPO-926:
# Title
# Description
# Attribution
# Date
# Contributors
# Coverage
# Creator
# Format
# Identifier
# Publisher
# Subject
RSpec.describe "when searching", :clean, type: :system, js: true do
  let(:item_one)        { "Ednah A. Rich" }
  let(:item_two)        { "Group photograph in front of Anna S. C. Blake Manual Training School" }
  let(:item_three)      { "Miss Anna S.C. Blake" }

  let(:csv_file_path)   { File.join(fixture_path, csv_file_name) }
  let(:csv_file_name)   { "blake_search_test.csv" }
  let(:site_admin)      { FactoryBot.create(:omniauth_site_admin) }
  let(:exhibit_slug)    { "the-anna-s-c-blake-manual-training-school" }
  let(:search_url)      { "/starlight/#{exhibit_slug}/catalog?utf8=%E2%9C%93&exhibit_id=#{exhibit_slug}&search_field=all_fields&q=" }
  let(:exact_title)     { "Ednah A. Rich" }
  let(:partial_title)   { "Ednah" }
  let(:description)     { "apple" }
  let(:attribution)     { "Whitman" }

  before do
    enable_selenium_file_detector
    stub_http_image_uploads

    allow(Spotlight::DefaultThumbnailJob).to receive(:perform_later)
    omniauth_setup_dev_auth_for(site_admin)
    sign_in
  end

  context "when searching specified fields" do
    it "returns the records we expect" do
      expect(Spotlight::Exhibit.count).to eq 0
      visit "/"
      exhibit = Spotlight::Exhibit.create!(title: "The Anna S. C. Blake Manual Training School")
      exhibit.import(JSON.parse(Rails.root.join("spec", "fixtures", "the-anna-s-c-blake-manual-training-school-export.json").read))
      exhibit.save
      exhibit.reindex_later
      expect(Spotlight::Exhibit.count).to eq 1
      visit("/starlight/the-anna-s-c-blake-manual-training-school/resources/new")
      click_link "Upload multiple items"
      expect(page).to have_content "CSV File"
      page.attach_file("resources_csv_upload[url]", csv_file_path)
      click_button "Add item"
      visit search_url
      expect(page).to have_content "Miss Anna S.C. Blake"
      click_link "Miss Anna S.C. Blake"
      expect(page).to have_content "uarch112-g01650"

      # IIIF Manifest present on the page
      expect(page.html).to match(%r{/starlight/the-anna-s-c-blake-manual-training-school/catalog/[[:digit:]]-[[:digit:]]/manifest})

      # UV present on the page
      expect(page).to have_selector ".universal-viewer-iframe"

      visit "#{search_url}#{exact_title}"
      expect(page).to have_content item_one
      expect(page).not_to have_content item_two
      expect(page).not_to have_content item_three

      ## Partial title search
      visit "#{search_url}#{partial_title}"
      expect(page).to have_content item_one
      expect(page).not_to have_content item_two
      expect(page).not_to have_content item_three

      ## Description search
      visit "#{search_url}#{description}"
      expect(page).to have_content item_one
      expect(page).not_to have_content item_two
      expect(page).to have_content item_three

      ## Attribution search
      visit "#{search_url}#{attribution}"
      expect(page).to have_content item_one
      expect(page).not_to have_content item_two
      expect(page).not_to have_content item_three
    end
  end
end
