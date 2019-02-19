unless Rails.env.production?
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
        begin
          require 'rspec/core/rake_task'
          RSpec::Core::RakeTask.new(:spec) do |t|
            t.rspec_opts = "--format RspecJunitFormatter --out rspec.xml"
          end
          Rake::Task['spec'].invoke
        rescue LoadError
          raise 'No RSpec available'
        end
      end
    end
  end
end
