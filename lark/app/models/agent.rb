# frozen_string_literal: true

##
# A full Agent record built from/saved to the index.
#
# @example creating and destroying an agent
#   agent = Agent.new(id: 'my_id', pref_label: 'An Agent')
#   adapter = Valkyrie::MetadataAdapter.find(Lark.config.index_adapter)
#
#   adapter.persister.save(resource: agent)
#   adapter.query_service.find_by(id: 'my_id') # => <#Agent ...>
#   adapter.persister.delete(resource: agent)
#
Valkyrie.config.resource_class_resolver.call(:Agent).class_eval do
end
