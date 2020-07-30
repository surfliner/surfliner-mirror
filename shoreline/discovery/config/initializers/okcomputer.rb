# frozen_string_literal: true

# Mount the health endpoint at /healthz
# Review all health checks at /health/all
OkComputer.mount_at = 'healthz'

# Setup additional services

solr_url = "http://#{ENV.fetch('SOLR_HOST')}:#{ENV.fetch('SOLR_PORT')}/solr/#{ENV.fetch('SOLR_CORE_NAME')}"
OkComputer::Registry.register 'solr', OkComputer::HttpCheck.new(solr_url)

class GeoServerCheck < OkComputer::Check
  def check
    conn = Geoserver::Publish::Connection.new(
      'url' => "http://#{ENV.fetch('GEOSERVER_HOST')}:#{ENV.fetch('GEOSERVER_PORT')}/geoserver/rest",
      'user' => ENV.fetch('GEOSERVER_USER'),
      'password' => ENV.fetch('GEOSERVER_PASSWORD')
    )

    if conn.get(path: '/')
      mark_message 'GeoServer is running'
    else
      mark_failure
      mark_message 'Failed to connect to GeoServer'
    end
  end
end

OkComputer::Registry.register 'geoserver', GeoServerCheck.new
