# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Unpublish Object", type: :system, js: true do
  let(:user) { User.find_or_create_by(email: "comet-admin@library.ucsb.edu") }

  let(:collection_type) { Hyrax::CollectionType.create(title: "Test Type") }
  let(:collection_type_gid) { collection_type.to_global_id.to_s }

  let(:collection) do
    col = Hyrax::PcdmCollection.new(title: ["Test Collection"], collection_type_gid: collection_type_gid)
    Hyrax.persister.save(resource: col)
  end

  let(:object) do
    obj = ::GenericObject.new(title: ["Test Object"], member_of_collection_ids: [collection.id])
    Hyrax.persister.save(resource: obj)
  end

  before {
    sign_in(user)

    Hyrax::Collections::PermissionsCreateService.create_default(collection: collection, creating_user: user)
    collection.permission_manager.read_users += [user.user_key]
    collection.permission_manager.edit_users += [user.user_key]
    collection.permission_manager.acl.save

    Hyrax.index_adapter.save(resource: collection)
    Hyrax.index_adapter.save(resource: object)
  }

  context "unpublish object" do
    let(:queue_message) { [] }

    it "has the unpublish button" do
      visit main_app.hyrax_generic_object_path(id: object.id)

      expect(page).to have_link("Unpublish")
    end

    it "can unpublish an object" do
      visit main_app.hyrax_generic_object_path(id: object.id)

      click_on "Unpublish"

      alert = page.driver.browser.switch_to.alert

      expect(alert.text).to have_content("Are you sure you want to unpublish the object?")
      alert.dismiss

      publish_wait(queue_message, 0) do
        expect(page).to have_content("The unpublish object request is submitted successfully.")
      end
    end
  end
end
