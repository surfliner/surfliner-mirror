# frozen_string_literal: true

require "rails_helper"

RSpec.describe Bulkrax::CsvEntry do
  describe "Export metadata" do
    subject(:csv_entry) do
      described_class.new(importerexporter: exporter, identifier: work.id)
    end

    let(:user) { User.find_or_create_by(email: "comet-admin@library.ucsb.edu") }

    context "with object fields and no prefix" do
      let(:work) do
        w = GenericObject.new(title: "Test Object Title",
          title_alternative: "An Alternative Title",
          creator: "Tester")
        Hyrax.persister.save(resource: w)
      end

      let(:exporter) do
        Bulkrax::Exporter.new(name: "Export from Importer",
          user: user,
          export_type: "metadata",
          export_from: "importer",
          export_source: "importer_1",
          parser_klass: "Bulkrax::CometCsvParser",
          limit: 0,
          field_mapping: {},
          generated_metadata: false)
      end

      describe "#build_export_metadata" do
        it "populates metadata" do
          expect(csv_entry.build_export_metadata)
            .to include "title" => "Test Object Title",
              "title_alternative" => "An Alternative Title",
              "creator" => "Tester"
        end
      end
    end
  end
end
