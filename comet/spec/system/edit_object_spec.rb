# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Objects", type: :system, js: true do
  let(:collection) do
    FactoryBot.valkyrie_create(:collection, :with_permission_template, user: user)
  end

  let(:user) { User.find_or_create_by(email: "comet-admin@library.ucsd.edu") }

  before do
    collection # create the collection explictly
    sign_in user
  end

  context "from the object page" do
    let(:object) do
      obj = GenericObject.new(title: "Object Added to Collection by Spec",
        visibility: "open",
        edit_users: [user])
      obj = Hyrax.persister.save(resource: obj)
      Hyrax.index_adapter.save(resource: obj)
      obj
    end
    
    it "can edit the object after assigning the collection to it" do
      visit main_app.hyrax_generic_object_path(id: object.id, locale: "en")

      click_button "Add to collection"
      select_member_of_collection(collection)
      click_button "Save changes"

      expect(object.member_of_collection_ids).to contain_exactly collection.id

      visit main_app.hyrax_generic_object_path(id: object.id)

      click_on "Edit"

      expect(page).to have_content(object.title.first)
    end
  end
end
