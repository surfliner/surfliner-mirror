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
class Concept < Valkyrie::Resource
  SCHEMA = "http://www.w3.org/2004/02/skos/core#ConceptScheme"

  include Lark::Schema(:concept)
end
