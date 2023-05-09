module TestQueries
  class FindFileMetadata < CustomQueries::FindFileMetadata
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
