# frozen_string_literal: true

##
# For geospatial data batch upload that accepts files to upload via `#add` and attaches them to a Work
# with `#attach`, without all the asychronous handling of the default Hyrax
# implementation.
#
# @todo replace `Lockable` Redis locks with database transactions?
class InlineBatchUploadGeodataHandler < InlineBatchUploadHandler
  PRIMARY_FILE_EXTENSION = ".shp"

  ##
  # @api public
  #
  # Create filesets for each added file, then push the uploads to the storage
  # backend.
  #
  # @return [Boolean]
  def attach
    return true if Array.wrap(files).empty?

    event_payloads = []

    acquire_lock_for(work.id) do
      main_file = files.find { |file| file.file.filename.end_with?(PRIMARY_FILE_EXTENSION) }

      event_payloads = Array.wrap(attach_member(file: main_file))

      @persister.save(resource: work) &&
        Hyrax.publisher.publish("object.metadata.updated", object: work, user: files.first.user)

      files.each { |file| file.file_set_uri = main_file.file_set_uri }
    end

    event_payloads.each { |payload| Hyrax.publisher.publish("file.set.attached", payload) }
    ingest(files: files)
  end
end
