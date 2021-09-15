# frozen_string_literal: true
#
# TODO:  "visibility_ssi":"restricted" -> we have no way of setting this in the collection form.
#   And the "Add the collection" button on the Work page complains about this
#   Even with visibility defaulting to "restricted" I would still expect the User can use their own restricted
#   collection?
#
# TODO: during object creation, it uses the following URL to search for collections:
# http://comet.k3d.localhost/authorities/search/collections?access=deposit&q=My&_=1631744557641
#   This is using QA, and just returns an empty json set. Possibly also visibility related, possibly a deeper issue

require "rails_helper"

RSpec.describe "Generic Objects", type: :system, js: true, storage_adapter: :memory, metadata_adapter: :test_adapter do
  let(:user) { User.find_or_create_by(email: "comet-admin@library.ucsb.edu") }
  let(:collection) do
    c = Hyrax::PcdmCollection.new(title: ["My Collection"])
    Hyrax.persister.save(resource: c)
  end

  before { sign_in user }

  context "during object creation" do
    it "can create a new object and assign a Collection to it" do
      visit "/dashboard/my/works"
      click_on "Add new work"
      fill_in("Title", with: "My Title")
      click_on "Relationships"
      click_on "Select a collection"
      # TODO: type in "My Collection"
      # TODO: expect a result
    end
  end

  context "after object creation" do
    it "can create a new object and assign a Collection to it after creation" do
      visit "/dashboard/my/works"
      click_on "Add new work"
      fill_in("Title", with: "My Title")
      click_on "Save"

      click_on "Add to collection"
      # TODO: expect it not to fail with a visibility error
    end
  end
end
