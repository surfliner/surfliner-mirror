# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Components", type: :system, js: true do
  let(:user) { User.find_or_create_by(email: "comet-admin@library.ucsb.edu") }

  before { sign_in user }

  it "can create a new collection and add object" do
    visit "/admin/collection_types"
    click_on "Create new collection type"
    fill_in("Type name", with: "Curated Collection")
    click_on "Save"

    visit "/dashboard"
    click_on "Collections"
    expect(page).to have_link("New Collection")

    click_on "New Collection"
    fill_in("Title", with: "System Spec Collection")

    expect { click_on("Save") }
      .to change { Hyrax.query_service.count_all_of_model(model: Hyrax::PcdmCollection) }
      .by 1

    expect(page).to have_content("Collection was successfully created.")
    # expect(page).to have_content("System Spec Collection")
  end
end
