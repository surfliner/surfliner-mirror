# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Components", type: :system, js: true do
  let(:parent_object) { Hyrax.persister.save(resource: GenericObject.new(title: "Parent Object")) }
  let(:user) { User.find_or_create_by(email: "comet-admin@library.ucsb.edu") }

  before do
    sign_in user
    Hyrax.index_adapter.save(resource: parent_object) # index the resource
  end

  it "can attach new objects as components" do
    visit "/concern/generic_objects/#{parent_object.id}"

    click_button("Add Component")
    click_on("Attach Generic object")

    fill_in("Title", with: "Component")
    choose("generic_object_visibility_open")
    click_on("Save")

    reloaded = Hyrax.query_service.find_by(id: parent_object.id)
    expect(reloaded.member_ids).not_to be_empty

    component = Hyrax.query_service.find_by(id: reloaded.member_ids.first)
    expect(component.title).to contain_exactly("Component")
  end
end
