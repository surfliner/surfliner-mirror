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
      find(:css, "#importer_parser_klass").find("option[value='Bulkrax::CometCsvParser']").select_option
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

    context "import records with no source identifier" do
      let(:source_file) { Rails.root.join("spec", "fixtures", "bulkrax", "missing_source_id.csv") }

      it "can successfully create and import" do
        visit "/dashboard"
        click_on "Importers"
        click_on "New"

        fill_in("Name", with: "importer_no_source_id")

        find(:css, "#importer_admin_set_id").find(:xpath, "option[2]").select_option
        find(:css, "#importer_parser_klass").find("option[value='Bulkrax::CometCsvParser']").select_option
        choose("importer_parser_fields_file_style_upload_a_file")
        attach_file "File", source_file

        click_button "Create and Import"

        expect(page).to have_content("Importer was successfully created and import has been queued.")

        validate_object_no_source_id_wait

        click_on "Importers"
        expect(page).to have_content("Complete")
      end
    end

    context "import records with property using multiple csv headers" do
      let(:source_file) { Rails.root.join("spec", "fixtures", "bulkrax", "property_multiple_headers.csv") }
      it "can successfully create multiple records for a property using multiple headers" do
        visit "/dashboard"
        click_on "Importers"
        click_on "New"

        fill_in("Name", with: "importer_multivalue_columns")

        find(:css, "#importer_admin_set_id").find(:xpath, "option[2]").select_option
        find(:css, "#importer_parser_klass").find("option[value='Bulkrax::CometCsvParser']").select_option
        choose("importer_parser_fields_file_style_upload_a_file")
        attach_file "File", source_file

        click_button "Create and Import"

        expect(page).to have_content("Importer was successfully created and import has been queued.")

        validate_object_wait(alternate_id: "w2")
        click_on "Importers"

        click_on "importer_multivalue_columns"

        expect(page).to have_content("w1")
        expect(page).to have_content("w2")

        # check the 1st record in the csv
        click_on "w1"
        expect(page).to have_content("Raw Metadata:")

        within("#parsed-metadata-heading") do
          find(".accordion-title").click
        end

        expect(page).to have_content("[\"Creator 1\", \"Creator 2\"]")

        within("div.main-content") do
          within("nav") do
            click_on "importer_multivalue_columns"
          end
        end

        click_on "w2"
        expect(page).to have_content("Raw Metadata:")

        within("#parsed-metadata-heading") do
          find(".accordion-title").click
        end

        expect(page).to have_content("[\"Creator 2\", \"Creator 3\"]")
      end
    end

    context "import records with delimited column values" do
      let(:source_file) { Rails.root.join("spec", "fixtures", "bulkrax", "multivalue_columns.csv") }
      it "can successfully split a delimited column value into multiple values" do
        visit "/dashboard"
        click_on "Importers"
        click_on "New"

        fill_in("Name", with: "importer_multivalue_columns")

        find(:css, "#importer_admin_set_id").find(:xpath, "option[2]").select_option
        find(:css, "#importer_parser_klass").find("option[value='Bulkrax::CometCsvParser']").select_option
        choose("importer_parser_fields_file_style_upload_a_file")
        attach_file "File", source_file

        click_button "Create and Import"

        expect(page).to have_content("Importer was successfully created and import has been queued.")

        validate_object_wait(alternate_id: "w2")
        click_on "Importers"

        click_on "importer_multivalue_columns"

        expect(page).to have_content("w1")
        expect(page).to have_content("w2")

        # check the 1st record in the csv
        click_on "w1"
        expect(page).to have_content("Raw Metadata:")

        within("#parsed-metadata-heading") do
          find(".accordion-title").click
        end

        expect(page).to have_content("[\"Creator 1\", \"Creator 2\"]")

        within("div.main-content") do
          within("nav") do
            click_on "importer_multivalue_columns"
          end
        end

        click_on "w2"
        expect(page).to have_content("Raw Metadata:")

        within("#parsed-metadata-heading") do
          find(".accordion-title").click
        end

        expect(page).to have_content("[\"Creator 2\", \"Creator 3\"]")
      end
    end
  end
end
