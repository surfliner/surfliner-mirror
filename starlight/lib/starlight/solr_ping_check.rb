# frozen_string_literal: true

##
# Check a solr ping via `Blacklight.default_index`
#
# This check should fail if the solr server is unreachable
class Starlight::SolrPingCheck < OkComputer::Check
  def check
    if Blacklight.default_index.ping
      mark_message "Solr connection OK (ping)"
    else
      mark_failure
      mark_message "Solr connection failed (ping)"
    end
  end
end
