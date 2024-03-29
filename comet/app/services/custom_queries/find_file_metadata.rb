# frozen_string_literal: true

module CustomQueries
  ##
  # custom implementations for Hyrax::CustomQueries::FindFileMetadata for the
  # sequel adapter
  class FindFileMetadata
    def self.queries
      [:find_files,
        :find_file_metadata_by,
        :find_original_file,
        :find_extracted_text,
        :find_thumbnail,
        :find_many_file_metadata_by_ids,
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

      files_for_file_set(file_set).each { |fm| yield fm }
    end

    # Find a file metadata using a Valkyrie ID, and map it to a Hyrax::FileMetadata
    # @param id [Valkyrie::ID, String]
    # @return [Hyrax::FileMetadata]
    # @raise [Hyrax::ObjectNotFoundError]
    def find_file_metadata_by(id:)
      result = query_service.find_by(id: id)
      unless result.is_a? Hyrax::FileMetadata
        raise ::Valkyrie::Persistence::ObjectNotFoundError,
          "Result type #{result.internal_resource} for id #{id} is not a `Hyrax::FileMetadata`"
      end
      result
    end

    # Find original file id of a given file set resource, and map to file metadata resource
    # @param file_set [Hyrax::FileSet]
    # @return [Hyrax::FileMetadata]
    def find_original_file(file_set:)
      find_many_file_metadata_by_use(
        resource: file_set,
        use: Hyrax::FileMetadata::Use::ORIGINAL_FILE
      ).first
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

    # Find an array of file metadata using Valkyrie IDs, and map them to Hyrax::FileMetadata maintaining order based on given ids
    # @param ids [Array<Valkyrie::ID, String>]
    # @return [Array<Hyrax::FileMetadata>] or empty array if there are no ids or none of the ids map to Hyrax::FileMetadata
    # NOTE: Ignores non-existent ids and ids for non-file metadata resources.
    def find_many_file_metadata_by_ids(ids:)
      ids.map! do |id|
        raise ArgumentError, "id must be a Valkyrie::ID" unless
          id.is_a?(Valkyrie::ID) || id.is_a?(String)
        id.to_s
      end

      query_service
        .resources
        .where(Sequel.lit("(id::varchar) IN ?", ids))
        .where(internal_resource: "Hyrax::FileMetadata").map do |attributes|
        resource_factory.to_resource(object: attributes)
      end
    end

    def find_many_file_metadata_by_use(resource:, use:)
      return [] unless resource.try(:file_ids)
      return enum_for(:find_many_file_metadata_by_use, resource: resource, use: use) unless
        block_given?

      files_for_file_set(resource).each { |fm| yield fm if fm.type.include?(use) }
    end

    private

    ##
    # Yields the +FileMetadata+ objects corresponding to the provided +FileSet+.
    #
    # @note this relies on a private method in the +Valkyrie::Sequel+ query
    #   adapter.
    def files_for_file_set(file_set)
      query_service.run_query(find_file_metadata_by_file_set_id, file_set.id.id)
    end

    ##
    # this doesn't quite work. :(
    # intended for use by #find_many_file_metadata_by_use
    def find_file_metadata_by_file_set_id
      <<-SQL
          SELECT fm.* FROM orm_resources fs,
          jsonb_array_elements(fs.metadata->'file_ids') AS a(file_id)
          JOIN orm_resources fm ON (fm.metadata #>> '{file_identifier,0,id}')::TEXT = (a.file_id->>'id')::TEXT
          WHERE fs.id = ?
      SQL
    end
  end
end
