task ci: %w[rubocop spec_with_server]

desc 'Run tests with blacklight-test solr instance running'
task spec_with_server: [:environment] do
  require 'solr_wrapper'
  ENV['environment'] = 'test'
  solr_params = {
    port: 8985,
    verbose: true,
    managed: true
  }
  SolrWrapper.wrap(solr_params) do |solr|
    solr.with_collection(name: 'blacklight-test', persist: false, dir: Rails.root.join('solr', 'config')) do
      # run the tests
      # Rake::Task['spotlight:seed'].invoke
      Rake::Task['spec'].invoke
    end
  end
end
