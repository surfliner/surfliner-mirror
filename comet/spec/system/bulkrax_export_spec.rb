# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Bulkrax Export", type: :system, js: true do
  let(:user) { User.find_or_create_by(email: "comet-admin@library.ucsb.edu") }

  before do
    setup_workflow_for(user)
    sign_in user
  end

  context "bulkrax export" do
    let(:source_file) { Rails.root.join("spec", "fixtures", "bulkrax", "generic_objects.csv") }

    before do
      visit "/dashboard"
      click_on "Importers"
      click_on "New"

      fill_in("Name", with: "importer_validate")

      find(:css, "#importer_admin_set_id").find(:xpath, "option[2]").select_option
      find(:css, "#importer_parser_klass").find("option[value='Bulkrax::CsvParser']").select_option
      choose("importer_parser_fields_file_style_upload_a_file")
      attach_file "File", source_file

      click_button "Create and Import"

      expect(page).to have_content("Importer was successfully created and import has been queued.")

      validate_object_wait(alternate_id: "w1")
    end

    it "can successfully create and export" do
      visit "/dashboard"
      click_on "Exporters"
      click_on "New"

      fill_in("Name", with: "exporter_1")

      find(:css, "#exporter_export_type").find(:xpath, "option[2]").select_option
      find(:css, "#exporter_export_from").find(:xpath, "option[2]").select_option
      find(:css, "#exporter_export_source_importer").find(:xpath, "option[2]").select_option
      find(:css, "#exporter_parser_klass").find(:xpath, "option[2]").select_option

      click_button "Create and Export"

      expect(page).to have_content("Exporter was successfully created. A download link will appear once it completes.")

      click_on "Exporters"

      expect(page).to have_link("exporter_1")
    end
  end

  context "bulkrax export with files" do
    let(:upload_file_id) { Valkyrie::ID.new("fake://1") }
    let(:file_set) { Hyrax.persister.save(resource: Hyrax::FileSet.new(file_ids: [upload_file_id])) }
    let(:file_metadata) do
      Hyrax::FileMetadata.new(mime_type: "image/jpeg",
        file_set_id: file_set.id,
        file_identifier: upload_file_id,
        type: [::Valkyrie::Vocab::PCDMUse.OriginalFile])
    end
    let(:object) { GenericObject.new(member_ids: [file_set.id], rendering_ids: [file_set.id]) }

    before do
      Hyrax.persister.save(resource: file_metadata)
      Hyrax.index_adapter.save(resource: file_set)
      Hyrax.persister.save(resource: object)
    end

    it "can successfully create and export" do
      visit "/dashboard"
      click_on "Exporters"
      click_on "New"

      fill_in("Name", with: "exporter_1")

      find(:css, "#exporter_export_type").find(:xpath, "option[3]").select_option
      find(:css, "#exporter_export_from").find(:xpath, "option[4]").select_option
      find(:css, "#exporter_export_source_worktype").find(:xpath, "option[2]").select_option
      find(:css, "#exporter_parser_klass").find(:xpath, "option[2]").select_option

      click_button "Create and Export"

      expect(page).to have_content("Exporter was successfully created. A download link will appear once it completes.")
      expect(page).to have_link("exporter_1")
    end
  end
end
