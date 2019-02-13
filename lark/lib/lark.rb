require 'dry-configurable'

##
# The top-level module for the Lark project.
#
# @example configuration
#   Lark.config.index_adapter = :a_registered_valkyrie_adapter
#
module Lark
  extend Dry::Configurable

  setting :index_adapter, :solr
end
