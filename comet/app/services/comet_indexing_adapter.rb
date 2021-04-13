# frozen_string_literal: true

##
# A comet indexer because the Hyrax one hard codes the solr connection without
# authentication.
class CometIndexingAdapter < Valkyrie::Indexing::Solr::IndexingAdapter
  def connection_url
    ENV.fetch("SOLR_URL") { super }
  end
end
