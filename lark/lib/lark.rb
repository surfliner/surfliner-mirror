require 'dry/configurable'
require 'dry/system/container'

##
# The top-level module for the Lark project.
#
# @example configuration
#   Lark.config.index_adapter = :a_registered_valkyrie_adapter
#
module Lark
  extend Dry::Configurable

  setting :index_adapter, :solr

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
