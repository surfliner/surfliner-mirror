# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Bulkrax Import", type: :system, js: true do
  let(:user) { User.find_or_create_by(email: "comet-admin@library.ucsb.edu") }

  before do
    setup_workflow_for(user)
    sign_in user
  end

  context "bulkrax import" do
    let(:source_file) { Rails.root.join("spec", "fixtures", "bulkrax", "generic_objects.csv") }

    xit "can successfully create and validate" do
      visit "/dashboard"
      click_on "Importers"
      click_on "New"

      fill_in("Name", with: "importer_validate")

      find(:css, "#importer_admin_set_id").find(:xpath, "option[2]").select_option
      find(:css, "#importer_parser_klass").find(:xpath, "option[4]").select_option
      choose("importer_parser_fields_file_style_upload_a_file")
      attach_file "File", source_file

      click_button "Create and Validate"

      expect(page).to have_content("Importer validation completed. Please review and choose to either Continue with or Discard the import.")
      expect(page).to have_content("w1")
      expect(page).to have_content("w2")
      expect(page).to have_selector(".glyphicon.glyphicon-ok", count: 2)

      click_on "w1"
      expect(page).to have_content("Raw Metadata:")

      within("#raw-metadata-heading") do
        find(".accordion-title").click
      end

      expect(page).to have_content("Lovely Title")
    end
  end
end
