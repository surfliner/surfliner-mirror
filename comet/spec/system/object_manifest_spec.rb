# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Object Manifest", type: :system, js: true do
  let(:user) { User.find_or_create_by(email: "comet-admin@library.ucsb.edu") }
  before { sign_in user }

  context "after object creation" do
    it "can show object manifest" do
      visit "/dashboard/my/works"
      click_on "add-new-work-button"

      fill_in("Title", with: "My Title 7")
      choose("generic_object_visibility_open")

      # ensure that the form fields are fully populated
      sleep(1.seconds)
      click_on "Save"

      gobjs = Hyrax.query_service.find_all_of_model(model: GenericObject)
      persisted_object = gobjs.find do |gob|
        gob.title == ["My Title 7"]
      end

      visit "/concern/generic_objects/#{persisted_object.id}/manifest.json"
      expect(page).to have_content("My Title 7")
      expect(page).to have_content("http://iiif.io/api/presentation/2/context.json")
      expect(page).to have_content("sc:Manifest")
    end
  end
end
