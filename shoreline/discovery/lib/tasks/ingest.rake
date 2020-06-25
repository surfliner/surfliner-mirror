# frozen_string_literal: true

namespace :shoreline do
  desc 'publish a Shapefile in GeoServer and GeoBlacklight'
  task :publish, [:file_path] => :environment do |_t, args|
    conn = Geoserver::Publish::Connection.new(
      # Using internal hostname to avoid the nginx ingress, which limits filesize
      'url' => "http://#{ENV['GEOSERVER_INTERNAL_HOST']}:#{ENV['GEOSERVER_PORT']}/geoserver/rest",
      'user' => ENV['GEOSERVER_USER'],
      'password' => ENV['GEOSERVER_PASSWORD']
    )

    file = File.read(args[:file_path])
    file_id = File.basename(args[:file_path], File.extname(args[:file_path]))
    workspace = 'public'
    Geoserver::Publish.create_workspace(workspace_name: workspace, connection: conn)
    Geoserver::Publish::DataStore.new(conn).upload(workspace_name: workspace, data_store_name: file_id, file: file)

    Importer.run(args[:file_path])
  rescue StandardError => e
    puts e.message
  end
end
