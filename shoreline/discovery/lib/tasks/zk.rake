# frozen_string_literal: true

require 'zk'
namespace :shoreline do
  desc 'Upload Solr configuration files to ZooKeeper'
  task :solrconfig, %i[collection file_path] => :environment do |_t, args|
    zk_host = ENV['STARLIGHT_ZOOKEEPER_SERVICE_HOST']
    zk_port = ENV['STARLIGHT_ZOOKEEPER_SERVICE_PORT']

    schema = Pathname.new(args[:file_path]).join('schema.xml')
    solrconfig = Pathname.new(args[:file_path]).join('solrconfig.xml')

    ZK.open("#{zk_host}:#{zk_port}") do |zk|
      zk.create("/#{collection}/schema.xml", File.read(schema), or: :set)
      zk.create("/#{collection}/sorlconfig.xml", File.read(solrconfig), or: :set)
    end
  end
end
