# frozen_string_literal: true

require 'dry/configurable'
require 'dry/system/container'

require_relative 'lark/event_stream'
require_relative 'lark/indexer'
require_relative 'lark/record_parser'

##
# The top-level module for the Lark project.
#
# @example configuration
#   Lark.config.index_adapter = :a_registered_valkyrie_adapter
#
module Lark
  extend Dry::Configurable

  setting :event_adapter, :sql
  setting :index_adapter, :solr
  setting :event_stream,  EventStream.instance

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

    load_paths!('lib', 'app')
  end
end
