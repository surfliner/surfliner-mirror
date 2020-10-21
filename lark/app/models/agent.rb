# frozen_string_literal: true

require_relative 'authority'

##
# A full Agent record built from/saved to the index.
#
# @example creating and destroying a concept
#   agent = Agent.new(id: 'my_id', pref_label: 'An Agent')
#   adapter = Valkyrie::MetadataAdapter.find(Lark.config.index_adapter)
#
#   adapter.persister.save(resource: agent)
#   adapter.query_service.find_by(id: 'my_id') # => <#Agent ...>
#   adapter.persister.delete(resource: agent)
#
class Agent < Authority
  SCHEMA = 'http://www.w3.org/2004/02/skos/core#ConceptScheme'

  include Lark::Schema(:agent)
end
