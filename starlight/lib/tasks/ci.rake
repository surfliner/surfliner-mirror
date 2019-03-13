unless Rails.env.production?
  task ci: %w[rubocop spec_with_server]

  desc 'Run tests with blacklight-test solr instance running'
  task spec_with_server: [:environment] do
    require 'solr_wrapper'
    solr_params = {
      port: 8985,
      verbose: true,
      managed: true,
      instance_dir: Rails.root.join('tmp', 'solr-test')
    }
    SolrWrapper.wrap(solr_params) do |solr|
      solr.with_collection(name: 'blacklight-core',
                           persist: false,
                           dir: Rails.root.join('solr', 'config')) do
        Rake::Task['spec'].invoke
      end
    end
  end
end
