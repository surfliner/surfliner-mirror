# frozen_string_literal: true

##
# A full Concept record built from/saved to the index.
#
# @example creating and destroying a concept
#   concept = Concept.new(id: 'my_id', pref_label: 'A Concept')
#   adapter = Valkyrie::MetadataAdapter.find(Lark.config.index_adapter)
#
#   adapter.persister.save(resource: concept)
#   adapter.query_service.find_by(id: 'my_id') # => <#Concept ...>
#   adapter.persister.delete(resource: concept)
#
Valkyrie.config.resource_class_resolver.call(:Concept).class_eval do
end
