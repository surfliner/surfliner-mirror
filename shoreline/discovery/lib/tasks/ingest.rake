# frozen_string_literal: true

namespace :shoreline do
  desc 'ingest a Shapefile into geoserver'
  task ingest: :environment do
    new_conn = Geoserver::Publish::Connection.new(
      url: "http://#{ENV['GEOSERVER_HOST']}:#{ENV['GEOSERVER_PORT']}/geoserver/rest",
      user: ENV['GEOSERVER_USER'],
      password: ENV['GEOSERVER_PASSWORD']
    )
  end
end