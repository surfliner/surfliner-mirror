# frozen_string_literal: true

module CustomQueries
  ##
  # custom implementations for Hyrax::CustomQueries::FindFileMetadata for the
  # sequel adapter
  class FindFileMetadata
    def self.queries
      [:find_files,
        :find_original_file,
        :find_extracted_text,
        :find_thumbnail,
        :find_many_file_metadata_by_use]
    end

    def initialize(query_service:)
      @query_service = query_service
    end

    attr_reader :query_service
    delegate :resource_factory, to: :query_service

    def find_files(file_set:)
      return [] unless file_set.try(:file_ids)
      return enum_for(:find_files, file_set: file_set).to_a unless block_given?

      file_set.file_ids.each do |file_id|
        query_json = {file_identifier: [id: file_id.to_s]}.to_json
        refs = query_service.run_query(query_service.send(:find_inverse_references_with_model_query),
          query_json,
          "Hyrax::FileMetadata")
        refs.each { |fm| yield fm }
      end
    end

    # Find original file id of a given file set resource, and map to file metadata resource
    # @param file_set [Hyrax::FileSet]
    # @return [Hyrax::FileMetadata]
    def find_original_file(file_set:)
      find_many_file_metadata_by_use(
        resource: file_set,
        use: Hyrax::FileMetadata::Use::ORIGINAL_FILE
      ).first || raise(Valkyrie::Persistence::ObjectNotFoundError)
    end

    # Find extracted text id of a given file set resource, and map to file metadata resource
    # @param file_set [Hyrax::FileSet]
    # @return [Hyrax::FileMetadata]
    def find_extracted_text(file_set:)
      find_many_file_metadata_by_use(
        resource: file_set,
        use: Hyrax::FileMetadata::Use::EXTRACTED_TEXT
      ).first || raise(Valkyrie::Persistence::ObjectNotFoundError)
    end

    # Find thumbnail id of a given file set resource, and map to file metadata resource
    # @param file_set [Hyrax::FileSet]
    # @return [Hyrax::FileMetadata]
    def find_thumbnail(file_set:)
      find_many_file_metadata_by_use(
        resource: file_set,
        use: Hyrax::FileMetadata::Use::THUMBNAIL
      ).first || raise(Valkyrie::Persistence::ObjectNotFoundError)
    end

    def find_many_file_metadata_by_use(resource:, use:)
      return [] unless resource.try(:file_ids)
      return enum_for(:find_many_file_metadata_by_use, resource: resource, use: use) unless
        block_given?

      # TODO: replace this with an efficient query that joins on the resource.
      resource.file_ids.each do |file_id|
        query_json = {file_identifier: [id: file_id.to_s]}.to_json
        refs = query_service.run_query(query_service.send(:find_inverse_references_with_model_query),
          query_json,
          "Hyrax::FileMetadata")
        refs.each { |fm| yield fm if fm.type.include?(use) }
      end
    end

    private

    ##
    # this doesn't quite work. :(
    # intended for use by #find_many_file_metadata_by_use
    def _find_many_inverse_references_with_model_query
      <<-SQL
          SELECT file_metadata.* FROM orm_resources a,
          jsonb_array_elements(a.metadata->'file_ids') AS b(file_id)
          JOIN orm_resources file_metadata ON b.file_id->>'id' = file_metadata.metadata#>{file_identifier}->>'id' WHERE a.id = ?
          AND file_metadata.metadata @> ?
          AND file_metadata.internal_resource = ?
      SQL
    end
  end
end
