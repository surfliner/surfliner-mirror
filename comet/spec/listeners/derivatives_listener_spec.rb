# frozen_string_literal: true

require "rails_helper"

RSpec.describe DerivativesListener do
  subject(:listener) { described_class.new }

  let(:file_set) { Hyrax.persister.save(resource: Hyrax::FileSet.new(file_ids: "file1")) }
  let(:metadata) do
    m = Hyrax::FileMetadata.new(file_identifier: "file1", original_filename: "Moomin.jpg")
    Hyrax.persister.save(resource: m)
  end

  describe "#on_file_characterized" do
    let(:event) { Dry::Events::Event.new("file.characterized", payload) }
    let(:payload) do
      {file_metadata: metadata,
       file_set_id: file_set.id}
    end

    it "enqueues a job with te file_set and metadata object" do
      expect { listener.on_file_characterized(event) }
        .to have_enqueued_job(ValkyrieCreateDerivativesJob)
        .with(file_set.id, metadata.id)
    end

    context "when it is not an original_file?" do
      let(:metadata) do
        m = Hyrax::FileMetadata.new(file_identifier: "file1",
          original_filename: "Moomin.jpg",
          type: RDF::URI("http://example.com/use/other"))
        Hyrax.persister.save(resource: m)
      end

      it "does not enqueue a job" do
        expect { listener.on_file_characterized(event) }
          .not_to have_enqueued_job(ValkyrieCreateDerivativesJob)
      end
    end
  end
end
