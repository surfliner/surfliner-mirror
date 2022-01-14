# frozen_string_literal: true

class CometCharacterizeJob < Hyrax::ApplicationJob
  queue_as Hyrax.config.ingest_queue_name

  ##
  # @param [Hyrax::FileMetadata] metadata
  def perform(metadata)
    Hyrax.publisher.publish("object.file.uploaded", metadata: metadata)
  end
end
