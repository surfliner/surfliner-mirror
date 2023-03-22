# frozen_string_literal: true

##
# Accepts uploaded files via `#add` and attaches them to a Work
# with `#attach`, without all the asychronous handling of the default Hyrax
# implementation.
#
# @todo replace `Lockable` Redis locks with database transactions?
class InlineUploadHandler < Hyrax::WorkUploadsHandler
  ##
  # @api public
  #
  # Create filesets for each added file, then push the uploads to the storage
  # backend.
  #
  # @return [Boolean]
  def attach
    return true if Array.wrap(files).empty?

    ingest(files: files)
  end

  private

  ##
  # @api private
  def ingest(files:)
    files.each do |file|
      uploader = file.uploader

      FileIngest.upload(
        content_type: uploader.file.content_type,
        file_body: File.open(uploader.file.file),
        filename: uploader.file.original_filename,
        last_modified: file.created_at,
        permissions: target_permissions,
        size: uploader.file.size,
        user: file.user,
        work: work
      )
    end
  end
end
