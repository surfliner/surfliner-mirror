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

    5.times do # if `Save` takes a few seconds, that's okay.
      break if reloaded.member_ids.any?
      sleep(1)
      reloaded = Hyrax.query_service.find_by(id: parent_object.id)
    end
    # keep this expectation for a clear error message if the loop fails
    expect(reloaded.member_ids).not_to be_empty

    component = Hyrax.query_service.find_by(id: reloaded.member_ids.first)
    expect(component.title).to contain_exactly("Component")
  end

  context "search component objects" do
    let(:compoment_title) { "Test Component" }

    it "can search the component objects and add to the object" do
      visit "/dashboard/my/works"
      click_on "add-new-work-button"

      fill_in("Title", with: compoment_title)
      choose("generic_object_visibility_open")

      sleep(1.seconds)
      click_on "Save"

      expect(page).to have_content(compoment_title)

      visit "/concern/generic_objects/#{parent_object.id}/edit"

      click_on "Relationships"

      select_child_work(compoment_title)

      within all(".form-inline")[1] do
        click_on("Add")
      end

      expect(page).to have_content(compoment_title)
      expect(page).to have_button("Remove from this object")
    end
  end

  context "remove component from object" do
    let(:compoment_title) { "Component To Remove" }
    let(:success_massage) { I18n.t("hyrax.base.component_actions.remove.success") }
    let(:comfirm_message) { I18n.t("hyrax.base.form_child_work_relationships.confirm.text") }

    it "can remove the component" do
      visit "/concern/generic_objects/#{parent_object.id}"

      click_button("Add Component")
      click_on("Attach Generic object")

      fill_in("Title", with: compoment_title)
      choose("generic_object_visibility_open")
      click_on("Save")

      visit "/concern/generic_objects/#{parent_object.id}"

      expect(page).to have_content(compoment_title)
      expect(page).to have_button("Remove from this object")

      click_on("Remove from this object")
      alert = page.driver.browser.switch_to.alert

      expect(alert.text).to have_content(comfirm_message)
      alert.accept

      expect(page).to have_content(success_massage)
      expect(page).not_to have_content(compoment_title)
    end
  end
end
