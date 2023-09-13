# frozen_string_literal: true

require "rails_helper"

RSpec.describe Bulkrax::CometCsvParser do
  subject(:parser) { described_class.new(importer) }
  let(:importer) { nil }

  shared_context "with a real importer" do
    let(:csv_path) { Rails.root.join("spec", "fixtures", "bulkrax", "generic_objects.csv") }
    let(:project) { FactoryBot.valkyrie_create(:project) }
    let(:user) { FactoryBot.create(:user) }

    let(:importer) do
      Bulkrax::Importer.create(name: "test importer #{SecureRandom.uuid}",
        parser_klass: described_class,
        user_id: user.id,
        admin_set_id: project.id,
        parser_fields: {})
    end

    let(:uploaded) do
      FactoryBot.create(:uploaded_file, file: File.open(csv_path))
    end

    before do
      # Bulkrax controllers write this data after save and then resave the importer.
      # trying to do this on Importer#create runs into a circular dependency: we need
      # the parser instance to `write_import_file` and we need the importer to create
      # the parser instance.
      importer[:parser_fields]["import_file_path"] =
        parser.write_import_file(uploaded.file.file)

      importer.current_run
    end
  end

  describe "#create_objects", :integration do
    include_context "with a real importer"

    let(:csv_path) { Rails.root.join("spec", "fixtures", "bulkrax", "works_and_collections.csv") }

    it "enqueues jobs for works, collections, and relationships" do
      expect { parser.create_objects }
        .to have_enqueued_job(Bulkrax::ImportCollectionJob).exactly(:once)
        .and have_enqueued_job(Bulkrax::ImportWorkJob).exactly(:once)
        .and have_enqueued_job(Bulkrax::ScheduleRelationshipsJob).exactly(:once)
    end
  end

  describe "#valid_import?", :integration do
    include_context "with a real importer"

    it { is_expected.to be_valid_import }

    context "with an invalid csv" do
      let(:csv_path) { Rails.root.join("spec", "fixtures", "bulkrax", "cardinality-test.csv") }

      it { is_expected.not_to be_valid_import }

      it "populates errors" do
        parser.valid_import?

        expect(importer.current_status)
          .to have_attributes(status_message: "Failed",
            error_message: include("(w1): cardinality_test"))
      end
    end
  end

  describe "#records", :integration do
    include_context "with a real importer"

    it "has some records" do
      expect(parser.records).not_to be_empty
    end

    context "with works and collections" do
      let(:csv_path) { Rails.root.join("spec", "fixtures", "bulkrax", "works_and_collections.csv") }

      it "lists works and collections" do
        expect(parser.works).not_to be_empty
        expect(parser.collections).not_to be_empty

        expect(parser.records)
          .to contain_exactly(*(parser.works + parser.collections))
      end
    end
  end

  describe "#entry_class" do
    it "is the custom CsvParser" do
      expect(parser.entry_class).to eq Bulkrax::CometCsvEntry
    end
  end

  describe "#work_entry_class" do
    it "is the custom CsvParser" do
      expect(parser.work_entry_class).to eq Bulkrax::CometCsvEntry
    end
  end
end
