# frozen_string_literal: true

require "comet/publisher_otel_behavior"

module Comet
  # visibility and permission values for comet
  PERMISSION_TEXT_VALUE_COMET = "comet"
  PERMISSION_TEXT_VALUE_METADATA_ONLY = "metadata_only"
  PERMISSION_TEXT_VALUE_CAMPUS = "campus"
  VISIBILITY_TEXT_VALUE_COMET = "comet"
  VISIBILITY_TEXT_VALUE_METADATA_ONLY = "metadata_only"
  VISIBILITY_TEXT_VALUE_CAMPUS = "campus"

  ##
  # @return an OpenTelemetry tracer
  # @see https://opentelemetry.io/docs/instrumentation/ruby/manual/
  def tracer
    Rails.application.config.tracer
  end
  module_function :tracer
end
