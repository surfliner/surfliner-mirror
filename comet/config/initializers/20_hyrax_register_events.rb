# frozen_string_literal: true

if Rails.application.config.feature_collection_publish
  Hyrax.publisher.register_event("collection.publish")
  Hyrax.publisher.register_event("object.unpublish")
end

Hyrax.publisher.register_event("file.characterized")
