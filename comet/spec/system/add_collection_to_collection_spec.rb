# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Collections", type: :system, js: true, storage_adapter: :memory, metadata_adapter: :test_adapter do
  let(:user) { User.find_or_create_by(email: "comet-admin@library.ucsb.edu") }
  let(:child_collection) do
    FactoryBot.valkyrie_create(:collection,
      :with_permission_template,
      title: "Child Collection",
      user: user)
  end

  let(:parent_collection) do
    FactoryBot.valkyrie_create(:collection,
      :with_permission_template,
      title: "Parent Collection",
      user: user)
  end

  before { sign_in user }

  it "can add to parent collection" do
    parent_collection # create the parent

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

    visit "/dashboard/collections/#{parent_collection.id}?locale=en"
    expect(page).to have_content("Child Collection")
  end
end
