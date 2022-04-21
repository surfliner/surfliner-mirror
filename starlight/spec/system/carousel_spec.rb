# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Solr Documents Carousel Block", :clean, type: :system, js: true do
  let(:image_upload_file_path) { File.join(fixture_path, "/images/colima-dog.jpg") }
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:site_admin) { FactoryBot.create(:omniauth_site_admin) }
  let!(:feature_page) { FactoryBot.create(:feature_page, exhibit: exhibit) }

  before do
    omniauth_setup_dev_auth_for(site_admin)
    sign_in

    # Upload image for carousel
    visit spotlight.new_exhibit_resource_path(exhibit)
    click_link "Upload item"
    page.attach_file("resources_upload[url]", image_upload_file_path)
    fill_in("Title", with: "Colima")
    within "#new_resources_upload" do
      click_button "Add item"
    end

    # Setup Carousel widget block
    visit spotlight.edit_exhibit_feature_page_path(exhibit, feature_page)
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
