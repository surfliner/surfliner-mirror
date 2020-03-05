# frozen_string_literal: true

# rubocop:disable Layout/LineLength
namespace :shoreline do
  desc 'publish a Shapefile in geoserver'
  task :publish, [:file_path] => :environment do |_t, args|
    new_conn = Geoserver::Publish::Connection.new(
      'url' => "http://#{ENV['GEOSERVER_HOST']}:#{ENV['GEOSERVER_PORT']}/geoserver/rest",
      'user' => ENV['GEOSERVER_USER'],
      'password' => ENV['GEOSERVER_PASSWORD']
    )
    file_name = File.basename(args[:file_path])
    file_id = File.basename(args[:file_path], File.extname(args[:file_path]))

    Geoserver::Publish.shapefile(
      connection: new_conn,
      workspace_name: 'public',
      file_path: "file://#{ENV['GEOSERVER_DATA_DIR']}/#{file_name}",
      id: file_id,
      title: file_id.gsub('_', ' ')
    )
  end
end
# rubocop:enable Layout/LineLength
