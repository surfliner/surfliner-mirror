module Comet
  module Spec
    class FindFileMetadata < Hyrax::CustomQueries::FindFileMetadata
      def find_many_file_metadata_by_use(resource:, use:)
        return [] unless resource.try(:file_ids)

        results = query_service.find_all_of_model(model: Hyrax::FileMetadata)
        results.select do |fm|
          fm.file_set_id == resource.id && fm.type.include?(use)
        end
      end
    end
  end
end
