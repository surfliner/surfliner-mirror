# frozen_string_literal: true

unless Rails.env.production?
  task ci: %w[rubocop spec_with_server]

  desc "Run tests with blacklight-test solr instance running"
  task spec_with_server: [:environment] do
    require "solr_wrapper"
    solr_params = {
      instance_dir: Rails.root.join("tmp", "solr-test"),
      managed: true,
      port: 8985,
      verbose: true,
      version: "7.7.1",
    }
    SolrWrapper.wrap(solr_params) do |solr|
      solr.with_collection(name: "blacklight-core",
                           persist: false,
                           dir: Rails.root.join("solr", "config")) do
        Rake::Task["spec"].invoke
      end
    end
  end
end
