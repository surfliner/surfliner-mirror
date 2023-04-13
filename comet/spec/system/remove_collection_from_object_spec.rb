# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Generic Objects", type: :system, js: true do
  let(:collection) do
    FactoryBot.valkyrie_create(:collection, :with_permission_template, title: ["Test Collection"], user: user)
  end
  let(:user) { User.find_or_create_by(email: "comet-admin@library.ucsd.edu") }
  let(:comfirm_message) { I18n.t("hyrax.base.form_member_of_collections.confirm.text") }

  before do
    collection # create the collection explictly
    sign_in user
  end

  context "remove collection from object" do
    let(:object) do
      obj = GenericObject.new(title: "Object Added to Collection by Spec",
        visibility: "open",
        edit_users: [user])
      obj = Hyrax.persister.save(resource: obj)
      Hyrax.index_adapter.save(resource: obj)
      obj
    end

    it "remove a collection" do
      visit main_app.hyrax_generic_object_path(id: object.id, locale: "en")

      click_button "Add to collection"
      select_member_of_collection(collection)
      click_button "Save changes"

      expect(object.member_of_collection_ids).to contain_exactly collection.id
      expect(page).to have_content(object.title.first)

      visit main_app.hyrax_generic_object_path(id: object.id)
      expect(page).to have_content(object.title.first)

      click_on "Edit"
      click_on "Relationships"

      expect(page).to have_content("Test Collection")

      click_on "Remove from collection"
      click_on "Remove"
      expect(page).not_to have_content("Test Collection")
      click_button "Save changes"

      visit main_app.hyrax_generic_object_path(id: object.id)
      expect(page).not_to have_content("Test Collection")
    end
  end
end
