# frozen_string_literal: true

##
# @see doc/deploy.md
module Importer
  REFERENCES = {
    wfs: "#{ENV["GEOSERVER_URL"]}/geoserver/wfs",
    wms: "#{ENV["GEOSERVER_URL"]}/geoserver/wms"
  }

  # @param [Hash] metadata
  # @param [String] shapefile_url
  def self.ingest(metadata:, shapefile_url: nil)
    file_id = metadata["id"]
    merged_metadata = metadata.merge({"dct_references_s": geoserver_references(metadata: metadata)})

    if shapefile_url.present?
      publish_to_geoserver(file_url: shapefile_url, file_id: file_id)
      merged_metadata = merged_metadata.merge(hash_from_geoserver(id: file_id))
    end

    publish_to_geoblacklight(metadata: merged_metadata)
  end

  # @param [String] file_url
  # @param [String] file_id
  def self.publish_to_geoserver(file_url:, file_id:)
    conn = Geoserver::Publish::Connection.new(
      "url" => "#{ENV["GEOSERVER_INTERNAL_URL"]}/geoserver/rest",
      "user" => ENV["GEOSERVER_ADMIN_USER"],
      "password" => ENV["GEOSERVER_ADMIN_PASSWORD"]
    )

    file = URI.parse(file_url).open.read
    # file_id = File.basename(file_path, File.extname(file_path))
    workspace = ENV.fetch("GEOSERVER_WORKSPACE", "public")

    puts "-- Publishing to GeoServer as #{file_id}"

    Geoserver::Publish.create_workspace(workspace_name: workspace, connection: conn)
    Geoserver::Publish::DataStore.new(conn).upload(workspace_name: workspace, data_store_name: file_id, file: file)
  end

  def self.publish_to_geoblacklight(metadata:)
    solrdoc = JSON.parse(metadata.to_json)

    Blacklight.default_index.connection.add(solrdoc)
    puts "Committing changes to Solr"
    Blacklight.default_index.connection.commit
  end

  def self.hash_from_geoserver(id:)
    {
      layer_geom_type_s: get_layer_type("public:#{id}")
    }
  end

  def self.get_layer_type(name)
    connection = Faraday.new(headers: {"Content-Type" => "application/json"})
    connection.basic_auth(
      ENV["GEOSERVER_ADMIN_USER"],
      ENV["GEOSERVER_ADMIN_PASSWORD"]
    )

    url = "#{ENV["GEOSERVER_INTERNAL_URL"]}/geoserver/rest/layers/#{name}.json"

    ready = false
    tries = 10
    until ready || tries == 0
      begin
        JSON.parse(connection.get(url).body)
        ready = true
      rescue => e
        warn "#{name} not ready: #{e}"
        tries -= 1
      end
      sleep 5
    end
    raise "--- ERROR: failed to get #{name} from GeoServer" if tries == 0

    json = JSON.parse(connection.get(url).body)
    json["layer"]["defaultStyle"]["name"].titlecase
  end

  def self.geoserver_references(metadata:)
    JSON.parse(metadata["dct_references_s"]).merge(
      transform_reference_uris(REFERENCES)
    ).to_json
  end

  # @param [Hash] references
  # @return [Hash]
  def self.transform_reference_uris(references)
    references.map do |k, v|
      {Geoblacklight::Constants::URI[k] => v}
    rescue => e
      warn "Transforming #{k} to URI failed, skipping: #{e.message}"
    end.reduce(&:merge)
  end
end
