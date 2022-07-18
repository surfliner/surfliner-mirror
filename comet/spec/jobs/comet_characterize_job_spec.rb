# frozen_string_literal: true

require "rails_helper"

RSpec.describe CometCharacterizeJob do
  subject(:job) { described_class }

  let(:file_metadata) { Hyrax.persister.save(resource: Hyrax::FileMetadata.new(file_identifier: upload.id)) }
  let(:file) { Tempfile.new("moomin.txt").tap { |f| f.write("moomin file") } }
  let(:file_set) { Hyrax.persister.save(resource: Hyrax::FileSet.new) }
  let(:upload) { Hyrax.storage_adapter.upload(resource: file_set, file: file, original_filename: "moomin.txt") }

  describe "#perform" do
    let(:spy_service) do
      Class.new do
        attr_accessor :metadata, :file

        def run(metadata:, file:)
          self.metadata = metadata
          self.file = file
        end

        def args
          {metadata: metadata, file: file}
        end
      end.new
    end

    before do
      allow(Hyrax.config)
        .to receive(:characterization_service)
        .and_return(spy_service)
    end

    it "calls out to the characterization service" do
      expect { job.perform_now(file_metadata) }
        .to change { spy_service.args }
        .from({metadata: nil, file: nil})
        .to({metadata: file_metadata, file: upload})
    end
  end
end
