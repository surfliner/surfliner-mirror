require 'rails_helper'

RSpec.describe CustomQueries::FindFileMetadata, metadata_adapter: :comet_metadata_store, storage_adapter: :repository_s3 do
  subject(:query_handler) { described_class.new(query_service: query_service) }
  let(:query_service) { Valkyrie::MetadataAdapter.find(:comet_metadata_store).query_service }

  describe ".queries" do
    it "lists queries" do
      expect(described_class.queries).to eq [:find_file_metadata_by,
                                             :find_file_metadata_by_alternate_identifier,
                                             :find_many_file_metadata_by_ids,
                                             :find_many_file_metadata_by_use]
    end
  end

  describe "#find_many_file_metadata_by_use" do
    let(:file_set) { Hyrax.persister.save(resource: Hyrax::FileSet.new) }
    let(:upload_id) { Valkyrie::ID.new('fake://1') }
    let(:text_upload_id) { Valkyrie::ID.new('fake://2') }
    let(:other_upload_id) { Valkyrie::ID.new('fake://3') }

    let(:file_metadata_original) do
      fm = Hyrax::FileMetadata.new(file_identifier: upload_id)
      Hyrax.persister.save(resource: fm)
    end

    let(:file_metadata_derivative) do
      fm = Hyrax::FileMetadata
             .new(file_identifier: text_upload_id,
                  type: Hyrax::FileMetadata::Use.uri_for(use: :extracted_file))

      Hyrax.persister.save(resource: fm)
    end

    let(:file_metadata_other) do
      fm = Hyrax::FileMetadata
             .new(file_identifier: other_upload_id,
                  type: Hyrax::FileMetadata::Use.uri_for(use: :extracted_file))

      Hyrax.persister.save(resource: fm)
    end

    before do
      file_set.file_ids << upload_id
      file_set.file_ids << text_upload_id
      file_set.file_ids << other_upload_id
      Hyrax.persister.save(resource: file_set)

      file_metadata_original
      file_metadata_derivative
      file_metadata_other
    end

    it "finds the original" do
      use = Hyrax::FileMetadata::Use.uri_for(use: :original_file)
      expect(query_handler.find_many_file_metadata_by_use(resource: file_set, use: use))
        .to contain_exactly(file_metadata_original)
    end

    it "finds the derivatives" do
      use = Hyrax::FileMetadata::Use.uri_for(use: :extracted_file)
      expect(query_handler.find_many_file_metadata_by_use(resource: file_set, use: use))
        .to contain_exactly(file_metadata_derivative, file_metadata_other)
    end

    it "when given a URI not present finds none" do
      use = ::RDF::URI('http://example.com/nope')
      expect(query_handler.find_many_file_metadata_by_use(resource: file_set, use: use))
        .not_to be_any # no #empty? for enums
    end
  end
end
