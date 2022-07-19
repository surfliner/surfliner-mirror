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

  context "approve object with no ark" do
    before {
      allow(Ezid::Identifier).to receive(:mint).and_return("ark:/99999/fk4test")
    }

    it "assign an ARK" do
      visit "/dashboard"
      click_on "Objects"
      click_on "add-new-work-button"

      fill_in("Title", with: "Object in Workflow")
      choose("generic_object_visibility_open")
      click_on "Relationships"
      select "Test Project", from: "generic_object_admin_set_id"
      click_on("Save")

      id = page.current_path.split("/").last

      click_on "Review and Approval"
      choose("Approve")
      click_on("Submit")

      sleep(1.seconds)
      obj = Hyrax.query_service.find_by(id: id)
      expect(obj.ark.id).to be("ark:/99999/fk4test")
    end
  end

  context "approve object with an ark" do
    before {
      allow(Ezid::Identifier).to receive(:mint).and_return("ark:/99999/fk4newark")
    }

    it "assign an ARK" do
      visit "/dashboard"
      click_on "Objects"
      click_on "add-new-work-button"

      fill_in("Title", with: "Object in Workflow")
      choose("generic_object_visibility_open")
      click_on "Relationships"
      select "Test Project", from: "generic_object_admin_set_id"
      click_on("Save")

      id = page.current_path.split("/").last
      obj = Hyrax.query_service.find_by(id: id)
      obj.ark = "ark:/99999/fk4test"
      Hyrax.persister.save(resource: obj)
      Hyrax.index_adapter.save(resource: obj)

      visit "/concern/generic_objects/#{id}?locale=en"

      click_on "Review and Approval"
      choose("Approve")
      click_on("Submit")

      sleep(1.seconds)
      obj = Hyrax.query_service.find_by(id: id)
      expect(obj.ark.id).to be("ark:/99999/fk4test")
    end
  end
end
