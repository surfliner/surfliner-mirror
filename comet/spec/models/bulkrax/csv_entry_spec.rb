# frozen_string_literal: true

require "rails_helper"

module Bulkrax
  RSpec.describe CsvEntry do
    describe "Export metadata" do
      subject { described_class.new(importerexporter: exporter) }

      let(:user) { User.find_or_create_by(email: "comet-admin@library.ucsb.edu") }

      context "with object fields and no prefix" do
        let(:work_obj) { GenericObject.new(title: "Test Object Title", title_alternative: "An Alternative Title", creator: "Tester") }

        let(:exporter) do
          Bulkrax::Exporter.new(name: "Export from Importer",
            user: user,
            export_type: "metadata",
            export_from: "importer",
            export_source: "importer_1",
            parser_klass: "Bulkrax::CsvParser",
            limit: 0,
            field_mapping: {},
            generated_metadata: false)
        end

        before do
          allow(subject).to receive(:hyrax_record).and_return(work_obj)
          allow(work_obj).to receive(:id).and_return("test_object")
          allow(work_obj).to receive(:member_of_work_ids).and_return([])
          allow(work_obj).to receive(:in_work_ids).and_return([])
          allow(work_obj).to receive(:member_work_ids).and_return([])
        end

        it "succeeds" do
          metadata = subject.build_export_metadata

          expect(metadata["title"]).to eq("Test Object Title")
          expect(metadata["title_alternative"]).to eq("An Alternative Title")
          expect(metadata["creator"]).to eq("Tester")
        end
      end
    end
  end
end
