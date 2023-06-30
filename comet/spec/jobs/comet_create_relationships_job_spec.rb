# frozen_string_literal: true

require "rails_helper"

RSpec.describe CometCreateRelationshipsJob, type: :job do
  let(:user) { User.find_or_create_by(email: "comet-admin@library.ucsb.edu") }
  let(:source_identifier_parent) { "source_identifier_parent" }
  let(:source_identifier_child) { "source_identifier_child" }
  let(:create_relationships_job) { described_class.new }
  let(:importer) do
    Bulkrax::Importer.create(
      name: "CSV Import",
      admin_set_id: "test_project",
      user: user,
      frequency: "PT0S",
      parser_klass: "Bulkrax::CsvParser",
      limit: 10,
      parser_fields: {import_file_path: "spec/fixtures/bulkrax/parent_relationships.csv"},
      field_mapping: {}
    )
  end
  let(:component_entry) do
    Bulkrax::CsvEntry.create(
      identifier: "entry_work",
      type: "Bulkrax::CsvEntry",
      importerexporter: importer,
      raw_metadata: {},
      parsed_metadata: {}
    )
  end
  let(:collection) do
    FactoryBot.valkyrie_create(:collection,
      :with_index,
      title: ["A Collection"],
      alternate_ids: [])
  end
  let(:parent_object) do
    FactoryBot.valkyrie_create(:generic_object,
      :with_index,
      title: ["An Object"],
      alternate_ids: [source_identifier_parent])
  end
  let(:component_record) do
    FactoryBot.valkyrie_create(
      :generic_object,
      :with_index,
      title: ["A Component"],
      alternate_ids: [source_identifier_child]
    )
  end
  let(:pending_rel) { importer.current_run.pending_relationships.create(parent_id: object_id, child_id: component_id) }
  let(:object_id) { parent_entry.identifier }
  let(:component_id) { component_entry.identifier }
  let(:collection_id) { collection.id.to_s }

  before do
    allow_any_instance_of(Ability).to receive(:authorize!).and_return(true)

    allow(create_relationships_job).to receive(:reschedule)
    allow(::Hyrax.config).to receive(:curation_concerns).and_return([GenericObject])
    allow(parent_object).to receive(:save!)
    allow(component_record).to receive(:save!)

    allow(create_relationships_job).to receive(:find_record)
    allow(create_relationships_job).to receive(:find_record)
      .with(object_id, importer.current_run.id)
      .and_return([parent_entry, parent_object])
    allow(create_relationships_job).to receive(:find_record)
      .with(component_id, importer.current_run.id)
      .and_return([component_entry, component_record])

    pending_rel
  end

  describe "#perform" do
    context "when adding a work to a collection" do
      subject(:perform) do
        create_relationships_job.perform(
          parent_identifier: collection_id, # id
          importer_run_id: importer.current_run.id
        )
      end

      let(:parent_entry) do
        Bulkrax::CsvEntry.create(
          identifier: "other_identifier",
          type: "Bulkrax::CsvEntry",
          importerexporter: importer,
          raw_metadata: {},
          parsed_metadata: {}
        )
      end

      let(:pending_rel) { importer.current_run.pending_relationships.create(parent_id: collection_id, child_id: object_id) }

      before do
        allow(create_relationships_job).to receive(:find_record)
          .with(collection_id, importer.current_run.id)
          .and_return([nil, collection])
      end

      it "assigns the collection to parent's #member_of_collection_ids" do
        expect { perform }.to change(parent_object, :member_of_collection_ids).from([]).to([collection.id])
      end

      it "increments the processed relationships counter on the importer run" do
        expect { perform }.to change { importer.current_run.reload.processed_relationships }.by(1)
      end

      it "deletes the pending relationship" do
        expect { perform }.to change(Bulkrax::PendingRelationship, :count).by(-1)
      end

      it "does not reschedule the job" do
        perform
        expect(create_relationships_job).not_to have_received(:reschedule)
      end
    end

    context "when adding a component to an object" do
      subject(:perform) do
        create_relationships_job.perform(
          parent_identifier: object_id, # source_identifier
          importer_run_id: importer.current_run.id
        )
      end

      let(:parent_object) do
        FactoryBot.valkyrie_create(
          :generic_object,
          :with_index,
          title: ["Another Work"],
          alternate_ids: [source_identifier_parent]
        )
      end
      let(:parent_entry) do
        Bulkrax::CsvEntry.create(
          identifier: "other_identifier",
          type: "Bulkrax::CsvEntry",
          importerexporter: importer,
          raw_metadata: {},
          parsed_metadata: {}
        )
      end

      it "assigns the child to the parent's #member_ids" do
        expect { perform }.to change(parent_object, :member_ids).from([]).to([component_record.id])
      end

      it "increments the processed relationships counter on the importer run" do
        expect { perform }.to change { importer.current_run.reload.processed_relationships }.by(1)
      end

      it "deletes the pending relationship" do
        expect { perform }.to change(Bulkrax::PendingRelationship, :count).by(-1)
      end
    end
  end
end
