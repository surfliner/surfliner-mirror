# frozen_string_literal: true

##
# A comet indexer because the Hyrax one hard codes the solr connection without
# authentication.
class CometIndexingAdapter < Valkyrie::Indexing::Solr::IndexingAdapter
  def connection_url
    sprintf "http://%s:%s@%s:%s/solr/%s", ENV["SOLR_ADMIN_USER"], ENV["SOLR_ADMIN_PASSWORD"], ENV["SOLR_HOST"], ENV["SOLR_PORT"], ENV["SOLR_COLLECTION_NAME"]
  end
end
