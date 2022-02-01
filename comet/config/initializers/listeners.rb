# frozen_string_literal: true

Hyrax.publisher.register_event("collection.publish") if Rails.application.config.feature_collection_publish
