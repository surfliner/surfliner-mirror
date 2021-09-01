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

    # TODO: create and add objects to a collectiony
    # click_on "New Collection"
  end
end
