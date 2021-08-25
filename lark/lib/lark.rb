# frozen_string_literal: true

require "dry/configurable"
require "dry/system/container"
require "dry/validation"
require "yaml"

require_relative "lark/version"
require_relative "lark/event_stream"
require_relative "lark/indexer"
require_relative "lark/minter"
require_relative "lark/record_parser"
require_relative "lark/record_serializer"
require_relative "lark/schema"
require_relative "lark/reindexer"

##
# The top-level module for the Lark project.
#
# @example configuration
#   Lark.config.index_adapter = :a_registered_valkyrie_adapter
#
module Lark
  extend Dry::Configurable

  setting :database
  setting :event_adapter, :sql
  setting :index_adapter, :solr
  setting :minter, Lark::Minter
  setting :event_stream, EventStream.instance

  ##
  # The core container for the application.
  #
  # This handles autoloading and resolution of dependencies.
  #
  # @see https://dry-rb.org/gems/dry-system/container/
  class Core < Dry::System::Container
    configure do |config|
      config.name = :lark
      config.auto_register = %w[app]
    end

    load_paths!("lib", "app")
  end

  ##
  # A generic HTTP error. This error can be handled by a Controller or a Rack
  # middleware to emit appropriate HTTP response codes and messages.
  class RequestError < RuntimeError
    STATUS = 500

    ##
    # @return [Integer] an HTTP status code for this error
    def status
      self.class::STATUS
    end
  end

  ##
  # @see RequestError
  class UnsupportedMediaType < RequestError
    STATUS = 415
  end

  ##
  # @see RequestError
  class BadRequest < RequestError
    STATUS = 400
  end

  ##
  # @see RequestError
  class NotFound < RequestError
    STATUS = 404
  end
end
