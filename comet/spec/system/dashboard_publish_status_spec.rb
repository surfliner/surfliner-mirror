# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Dashboard Publication Status", type: :system, js: true, storage_adapter: :memory, metadata_adapter: :test_adapter do
  let(:user) { User.find_or_create_by(email: "comet-admin@library.ucsb.edu") }
  let(:platforms) { {} }

  before do
    sign_in(user)
    allow(DiscoveryPlatformService)
      .to receive(:call)
      .and_return(platforms)

    Hyrax::CollectionType.create(title: "Spec Type")

    visit "/admin/collection_types"
    click_on "Create new collection type"
    fill_in("Type name", with: "Curated Collection")
    click_on "Save"

    visit "/dashboard"
    click_on "Collections"
    find("#add-new-collection-button").click
    within("div#collectiontypes-to-create") do
      choose("Spec Type")
      click_on("Create collection")
    end
    fill_in("Title", with: "System Spec Collection")

    expect { click_on("Save") }
      .to change { Hyrax.query_service.count_all_of_model(model: Hyrax::PcdmCollection) }
      .by 1
  end

  context "with a published collection" do
    let(:platforms) { [["Tidewater", "http://tidewater/1234"]] }

    it "can show the publication status in the collection list" do
      visit "/dashboard/my/collections"
      expect(page).to have_content("Published")
    end
  end

  context "with an unpublished collection" do
    let(:platforms) { [] }

    it "can show the publication status in the collection list" do
      visit "/dashboard/my/collections"
      expect(page).to have_content("Unpublished")
    end
  end
end
