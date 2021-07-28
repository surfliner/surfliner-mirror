# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Base Workflow", type: :system, js: true do
  let(:user) { User.find_or_create_by(email: "comet-admin@library.ucsb.edu") }

  before { sign_in user }

  it "deposits items into workflow" do
    visit "/dashboard"
    click_on "Works"
    click_on "Add new work"

    fill_in("Title", with: "Object in Workflow")
    choose("generic_object_visibility_open")
    click_on "Relationships"
    select "Default Project", :from => "generic_object_admin_set_id"
    click_on("Save")

    id = page.current_path.split("/").last
    workflow_entity = Sipity::Entity(Hyrax.query_service.find_by(id: id))

    # expect(workflow_entity.workflow_state).to eq 'OMG'
  end
end
