# frozen_string_literal: true

class CometCharacterizeJob < Hyrax::ApplicationJob
  queue_as Hyrax.config.ingest_queue_name

  ##
  # @param [Hyrax::FileMetadata] metadata
  def perform(metadata)
    Hyrax.config.characterization_service.run(metadata: metadata, file: metadata.file)
  end
end
