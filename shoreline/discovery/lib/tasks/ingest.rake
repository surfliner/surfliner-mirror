# frozen_string_literal: true

# rubocop:disable Layout/LineLength
namespace :shoreline do
  desc 'publish a Shapefile in geoserver'
  task ingest: :environment do
    new_conn = Geoserver::Publish::Connection.new(
      url: "http://#{ENV['GEOSERVER_HOST']}:#{ENV['GEOSERVER_PORT']}/geoserver/rest",
      user: ENV['GEOSERVER_USER'],
      password: ENV['GEOSERVER_PASSWORD']
    )
    new_conn
  end
end
# rubocop:enable Layout/LineLength
