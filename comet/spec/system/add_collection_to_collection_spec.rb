# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Collections", type: :system, js: true, storage_adapter: :memory, metadata_adapter: :test_adapter do
  let(:user) { User.find_or_create_by(email: "comet-admin@library.ucsb.edu") }
  let!(:collection_type) { Hyrax::CollectionType.create(title: "Spec Type") }
  before { sign_in user }

  it "can create a new collection and add to parent collection" do
    # Create parent collection
    visit "/dashboard"
    click_on "Collections"
    click_on "New Collection"
    fill_in("Title", with: "Parent Collection")
    click_on("Save")

    # Create child collection
    visit "/dashboard"
    click_on "Collections"
    click_on "New Collection"
    fill_in("Title", with: "Child Collection")
    click_on("Save")

    expect(page).to have_content("Collection was successfully created.")
    expect(page).to have_content("Parent Collection")
    expect(page).to have_content("Child Collection")

    persisted_collections = Hyrax.query_service.find_all_of_model(model: Hyrax::PcdmCollection)
    _parent_collection = persisted_collections.find do |col|
      col.title == ["Parent Collection"]
    end

    child_collection = persisted_collections.find do |col|
      col.title == ["Child Collection"]
    end

    # Add child collection to parent collection
    visit "/dashboard/collections/#{child_collection.id}?locale=en"
    expect(page).to have_content("Child Collection")
    click_button("Add to collection", exact: true)

    expect(page).to have_content("Add this Collection Within Another Collection")
    expect(page).to have_content("Select collection")
    select("Parent Collection", from: "parent_id").select_option
    click_button "Add to collection", class: "modal-submit-button"
    expect(page).to have_content("'Child Collection' has been added to 'Parent Collection'")

    visit "/dashboard/collections/#{child_collection.id}?locale=en"
    expect(page).to have_content("Parent Collection")
  end
end