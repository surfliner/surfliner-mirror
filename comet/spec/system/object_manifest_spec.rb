# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Object Manifest", type: :system, js: true do
  let(:user) { User.find_or_create_by(email: "comet-admin@library.ucsb.edu") }
  before { sign_in user }
  let(:file_set) { Hyrax.persister.save(resource: Hyrax::FileSet.new) }
  let(:file) { Tempfile.new("moomin.jpg").tap { |f| f.write("moomin picture") } }
  let(:upload) { Hyrax.storage_adapter.upload(resource: file_set, file: file, original_filename: "Moomin.jpg") }
  let(:file_metadata) do
    Hyrax::FileMetadata.new(file_identifier: upload.id, alternate_ids: upload.id, original_filename: "Moomin.jpg")
  end
  let(:object) do
    Hyrax.persister.save(resource:
      GenericObject.new(
        title: ["Comet in Moominland"],
        creator: "Tove Jansson",
        rights_statement: "free!",
        member_ids: [file_set.id]
      ))
  end
  before do
    file_set.file_ids << upload.id
    Hyrax.persister.save(resource: file_set)
    Hyrax.persister.save(resource: file_metadata)
    Hyrax.index_adapter.save(resource: object)
  end

  context "after object creation" do
    it "can show manifest for object has no attachment" do
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
      expect(page).to_not have_content("sc:Canvas")
    end

    it "can show manifest for object that has attachment" do
      visit "/concern/generic_objects/#{object.id}/manifest.json"
      expect(page).to have_content("Comet in Moominland")
      expect(page).to have_content("http://iiif.io/api/presentation/2/context.json")
      expect(page).to have_content("sc:Canvas")
    end
  end
end
