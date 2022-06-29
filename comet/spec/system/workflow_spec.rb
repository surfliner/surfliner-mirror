# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Base Workflow", type: :system, js: true do
  let(:workflow_name) { "surfliner_default" }
  let(:approving_user) { User.find_or_create_by(email: "comet-admin@library.ucsb.edu") }

  before {
    setup_workflow_for(approving_user)
    sign_in approving_user
  }

  it "deposits items into workflow" do
    visit "/dashboard"
    click_on "Objects"
    click_on "add-new-work-button"

    fill_in("Title", with: "Object in Workflow")
    choose("generic_object_visibility_open")
    click_on "Relationships"
    select "Test Project", from: "generic_object_admin_set_id"
    click_on("Save")

    id = page.current_path.split("/").last
    workflow_entity = Sipity::Entity(Hyrax.query_service.find_by(id: id))

    expect(workflow_entity.workflow_state).to have_attributes name: "in_review"
  end
end
