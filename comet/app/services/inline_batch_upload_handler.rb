# frozen_string_literal: true

##
# For batch upload that accepts files to upload via `#add` and attaches them to a Work
# with `#attach`, without all the asychronous handling of the default Hyrax
# implementation.
#
# @todo replace `Lockable` Redis locks with database transactions?
class InlineBatchUploadHandler < InlineUploadHandler
  private

  ##
  # @api private
  def ingest(files:)
    files.each do |file|
      file_metadata = Hyrax::FileMetadata.for(file: file.file)
      file_metadata.file_set_id = file.file_set_uri
      file_metadata = Hyrax.persister.save(resource: file_metadata)
      Hyrax::AccessControlList.copy_permissions(source: target_permissions, target: file_metadata)

      uploaded = Hyrax.storage_adapter
        .upload(resource: file_metadata,
          file: file.file.io_file,
          original_filename: file_metadata.original_filename)
      file_metadata.file_identifier = uploaded.id
      file_metadata.type = Hyrax::FileMetadata::Use.uri_for(use: file.file.file_use) unless file.file.file_use.nil?
      file_metadata.size = uploaded.size
      saved_metadata = Hyrax.persister.save(resource: file_metadata)
      Hyrax.publisher.publish("file.metadata.updated", metadata: saved_metadata, user: file.user)
      Hyrax.publisher.publish("object.file.uploaded", metadata: saved_metadata, file: uploaded)

      file_set = Hyrax.query_service.find_by(id: file.file_set_uri)
      file_set.file_ids << uploaded.id
      Hyrax.persister.save(resource: file_set)
    end
  end

  ##
  # @api private
  # @note ported from Hyrax::WorkUploadsHandler.
  # @return [Hash{Symbol => Object}]
  def file_set_args(file)
    {depositor: file.user.id,
     creator: file.user.id,
     date_uploaded: Hyrax::TimeService.time_in_utc,
     date_modified: Hyrax::TimeService.time_in_utc,
     label: file.file.filename,
     title: file.file.filename}
  end

  ##
  # @api private
  #
  # @note ported from Hyrax::WorkUploadsHandler.
  #
  # @raise [ArgumentError] if any of the uploaded files aren't the right class
  def validate_files(files)
    files.each do |file|
      next if file.is_a? ::BatchUploadFile
      raise ArgumentError, "BatchUploadFile required, but #{file.class} received: #{file.inspect}"
    end
  end
end
