# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Object Manifest", type: :system, js: true do
  let(:user) { User.find_or_create_by(email: "comet-admin@library.ucsb.edu") }
  before { sign_in user }

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
      expect(page).to_not have_content("canvas")
    end

    it "can show manifest for object that has attachment" do
      visit "/dashboard/my/works"
      click_on "add-new-work-button"

      click_link "Files"
      expect(page).to have_content "Add files"

      within("div#add-files") do
        attach_file("files[]", Rails.root.join("spec", "fixtures", "image.jpg"), visible: false)
      end

      click_link "Descriptions"
      fill_in("Title", with: "Test Image Object")
      choose("generic_object_visibility_open")

      # ensure that the form fields are fully populated
      sleep(1.seconds)
      click_on("Save")

      expect(page).to have_content("Test Image Object")
      gobjs = Hyrax.query_service.find_all_of_model(model: GenericObject)
      persisted_object = gobjs.find do |gob|
        gob.title == ["Test Image Object"]
      end
      expect(page).to have_link("Download", visible: :all)

      find(".attribute-filename").find("a").click
      expect(page).to have_content("File Details")

      visit "/concern/generic_objects/#{persisted_object.id}/manifest.json"
      # require "pry"; binding.pry
      expect(page).to have_content("Test Image Object")
      expect(page).to have_content("http://iiif.io/api/presentation/2/context.json")
      expect(page).to have_content("canvas")
    end

    it "can show manifest for object that has attachment" do
      visit "/dashboard/my/works"
      click_on "add-new-work-button"

      click_link "Files"
      expect(page).to have_content "Add files"

      within("div#add-files") do
        attach_file("files[]", Rails.root.join("spec", "fixtures", "image.jpg"), visible: false)
      end

      click_link "Descriptions"
        fill_in("Title", with: "Test Image Object")
      choose("generic_object_visibility_open")

      # ensure that the form fields are fully populated
      sleep(1.seconds)
      click_on("Save")

      expect(page).to have_content("Test Image Object")
      gobjs = Hyrax.query_service.find_all_of_model(model: GenericObject)
      persisted_object = gobjs.find do |gob|
        gob.title == ["Test Image Object"]
      end
      expect(page).to have_link("Download", visible: :all)

      find(".attribute-filename").find("a").click
      expect(page).to have_content("File Details")

      visit "/concern/generic_objects/#{persisted_object.id}/manifest.json"
      # require "pry"; binding.pry
      expect(page).to have_content("Test Image Object")
      expect(page).to have_content("http://iiif.io/api/presentation/2/context.json")
      expect(page).to have_content("canvas")
    end
  end
end
