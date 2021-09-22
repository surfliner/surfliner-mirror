# frozen_string_literal: true

##
# A base module to resolve requests for batch uploads.
module BatchUploadsControllerBehavior
  private

    def ingest_object(attrs, file_path)
      # object unique id
      attrs.delete :object_unique_id

      # bind source file
      src_file = "file://#{file_path}/#{attrs["file name"]}"
      attrs[:uploaded_files] = []
      attrs[:remote_files] = [src_file]

      # TODO: assign license, visibility, embargo_release_date etc.

      # TODO: add collections

      # ingest object
      ingest_log = Hyrax::Operation.create!(user: @user,
                                            operation_type: "Create Work",
                                            parent: @log)
      ObjectIngestJob.perform_now(@user, ::GenericObject.to_s, [attrs], ingest_log)
    end
end