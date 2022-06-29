# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Components", type: :system, js: true do
  let(:user) { User.find_or_create_by(email: "comet-admin@library.ucsb.edu") }

  before { sign_in user }

  it "can attach new objects as components" do
    visit "/dashboard"
    click_on "Objects"
    click_on "add-new-work-button"

    fill_in("Title", with: "Parent Object")
    choose("generic_object_visibility_open")
    click_on("Save")

    expect(page).to have_content("Parent Object")

    parent_id = page.current_path.split("/").last

    click_button("Add Component")
    click_on("Attach Generic object")

    fill_in("Title", with: "Component Object")
    choose("generic_object_visibility_open")
    click_on("Save")

    component_id = page.current_path.split("/").last
    parent = Hyrax.query_service.find_by(id: parent_id)

    expect(parent.member_ids).to contain_exactly(component_id)
  end
end
