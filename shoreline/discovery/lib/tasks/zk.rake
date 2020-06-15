# frozen_string_literal: true

require 'zk'
namespace :shoreline do
  desc 'Upload Solr configuration files to ZooKeeper'
  task :solrconfig, %i[dir_path] => :environment do |_t, args|
    zk_host = ENV['ZK_HOST']
    zk_port = ENV['ZK_PORT']

    ZK.open("#{zk_host}:#{zk_port}") do |zk|
      Dir.glob(Pathname.new(Dir.pwd).join(args[:dir_path]).join('*')) do |file|
        unless File.directory? file
          # https://github.com/apache/lucene-solr/blob/675956c0041b18d48a7c059ea458c49f5310d74a/solr/solrj/src/java/org/apache/solr/common/cloud/ZkConfigManager.java#L42
          warn "Uploading #{file} to /configs/solrconfig/#{File.basename(file)} ..."
          zk.create("/configs/solrconfig/#{File.basename(file)}", File.read(file), or: :set)
        end
      end
    end
  end
end
