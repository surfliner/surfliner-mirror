# frozen_string_literal: true

##
# Tools for configuring/maintaining Solr cloud
module SolrUtils
  Dir[File.expand_path(File.join(File.dirname(__FILE__), 'tasks/*.rake'))].each { |ext| load ext } if defined?(Rake)
end
