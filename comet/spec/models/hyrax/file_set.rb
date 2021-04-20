# frozen_string_literal: true

require "rails_helper"
require "hyrax/specs/shared_specs/hydra_works"

RSpec.describe Hyrax::FileSet do
  subject(:file_set) { described_class.new }

  it_behaves_like "a Hyrax::FileSet"

  describe "attaching a file" do
    subject(:file_set) { Hyrax.persister.save(resource: described_class.new) }
    let(:file) { Tempfile.new("moomin.jpg") }

    it "adds an id to file_ids" do
      expect { Hyrax.storage_adapter.upload(resource: file_set, file: file, original_filename: "Moomin.jpg") }
        .to change { Hyrax.query_service.find_by(id: file_set.id).file_ids }
        .from(0)
        .to 1
    end
  end
end
