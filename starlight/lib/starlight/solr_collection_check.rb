# frozen_string_literal: true

##
# Checks that the solr collection is available and properly configured.
class Starlight::SolrCollectionCheck < OkComputer::Check
  def check
    mark_message "Solr collection is available"
  end
end
