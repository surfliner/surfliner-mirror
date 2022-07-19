# frozen_string_literal: true

module Hyrax
  module Listeners
    class FileMetadataListener
      ##
      # Run derivatives when the file has been characterized if
      # appropriate.
      def on_file_characterized(event)
        # do nothing unless this is an :original_file
        metadata = event[:file_metadata]
        return :noop unless metadata&.original_file?

        Hyrax::ValkyrieCreateDerivativesJob
          .perform_later(event[:file_set_id], event[:file_id])
      end

      ##
      # Index the FileSet when the original_file's metadata is changed
      def on_file_metadata_updated(event)
        return unless event[:metadata].original_file?

        file_set = Hyrax.query_service.find_by(id: event[:metadata].file_set_id)
        Hyrax.index_adapter.save(resource: file_set)
      rescue Valkyrie::Persistence::ObjectNotFoundError => err
        Hyrax.logger.warn "tried to index file with id #{event[:metadata].id} " \
                          "in response to an event of type #{event.id} but " \
                          "encountered an error #{err.message}. should this " \
                          "object be in a FileSet #{event[:metadata]}"
      end

      ##
      # Run characterization in the background whenever a file is uploaded.
      def on_object_file_uploaded(event)
        ::CometCharacterizeJob.perform_later(event[:metadata])
      end
    end
  end
end
