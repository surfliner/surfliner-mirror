require "rails_helper"

RSpec.describe Bulkrax::CometCsvEntry do
  subject(:csv_entry) do
    described_class.new(importerexporter: exporter, identifier: work.id)
  end

  describe "Export metadata" do
    let(:user) { User.find_or_create_by(email: "comet-admin@library.ucsb.edu") }

    context "with object fields and no prefix" do
      let(:work) do
        w = GenericObject.new(title: "Test Object Title",
          title_alternative: "An Alternative Title",
          creator: "Tester",
          alternate_ids: ["w_1"])
        Hyrax.persister.save(resource: w)
      end

      let(:exporter) do
        Bulkrax::Exporter.new(name: "Export from Worktype",
          user: user,
          export_type: "metadata",
          export_from: "worktype",
          export_source: "GenericObject",
          parser_klass: "Bulkrax::CometCsvParser",
          limit: 0,
          generated_metadata: false)
      end

      before do
        allow_any_instance_of(Bulkrax::ValkyrieObjectFactory).to receive(:run!)
        allow(subject).to receive(:hyrax_record).and_return(work)
        allow(work).to receive(:id).and_return("w_1")
        allow(work).to receive(:member_of_work_ids).and_return([])
        allow(work).to receive(:in_work_ids).and_return([])
        allow(work).to receive(:member_work_ids).and_return([])
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
