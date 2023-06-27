module TestQueries
  class FindFileMetadata < CustomQueries::FindFileMetadata
    def find_file_metadata_by(id:)
      result = query_service.find_inverse_references_by(id: id.to_s, property: :file_identifier, model: Hyrax::FileMetadata)
      raise "Multiple results for same ID #{id} in find_file_metadata_by" unless result.size == 1
      result = result.first
      unless result.is_a?(Hyrax::FileMetadata)
        raise ::Valkyrie::Persistence::ObjectNotFoundError,
          "Result type #{result.internal_resource} for id #{id} is not a `Hyrax::FileMetadata`"
      end
      result
    end

    private

    def files_for_file_set(file_set)
      return enum_for(:files_for_file_set, file_set).to_a unless block_given?

      file_set.file_ids.each do |file_id|
        # A slower implementation for non‐SQL scenarios.
        query_service.find_inverse_references_by(
          id: file_id.to_s,
          property: :file_identifier,
          model: Hyrax::FileMetadata
        ).each { |fm| yield fm }
      end
    end
  end
end
