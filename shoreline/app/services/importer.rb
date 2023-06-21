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
    Rails.logger.debug "Received metadata: #{metadata}"
    parsed = if metadata.is_a? String
      JSON.parse(metadata)
    else
      metadata
    end.except("@context")

    Rails.logger.debug "Parsed metadata #{parsed}"

    file_id = metadata["id"]
    merged_metadata = if parsed["dct_references_s"].nil?
      parsed
    else
      parsed.merge({dct_references_s: geoserver_references(metadata: metadata)})
    end

    unless shapefile_url.nil?
      Rails.logger.info "Importing shapefile #{shapefile_url}"

      publish_to_geoserver(file_url: shapefile_url, file_id: file_id)
      merged_metadata = merged_metadata.merge(hash_from_geoserver(id: file_id))
    end

    unless is_metadata_valid?(merged_metadata)
      raise "--- ERROR: metadata failed validation against Aardvark schema: #{metadata}"
    end

    # puts "Finalized metadata: #{merged_metadata}"

    publish_to_geoblacklight(metadata: merged_metadata)
  rescue => e
    Rails.logger.error "Error ingesting into Shoreline"
    Rails.logger.error "#{e.message}: #{e.inspect}"
    Rails.logger.error e.backtrace
    raise e
  end

  # @param [String] file_url
  # @param [String] file_id
  def self.publish_to_geoserver(file_url:, file_id:)
    conn = Geoserver::Publish::Connection.new(
      "url" => "#{ENV["GEOSERVER_INTERNAL_URL"]}/geoserver/rest",
      "user" => ENV["GEOSERVER_ADMIN_USER"],
      "password" => ENV["GEOSERVER_ADMIN_PASSWORD"]
    )

    # file_id = File.basename(file_path, File.extname(file_path))
    workspace = ENV.fetch("GEOSERVER_WORKSPACE", "public")

    puts "-- Publishing to GeoServer as #{file_id}"

    # GeoServer claims to support uploading shapefiles by providing a url and
    # passing `url` as the method (instead of `file` and uploading a binary
    # stream), but this is not true.
    file = URI.parse(file_url).open.read

    Geoserver::Publish.create_workspace(workspace_name: workspace, connection: conn)
    Geoserver::Publish::DataStore.new(conn).upload(
      workspace_name: workspace,
      data_store_name: file_id,
      file: file,
      method: "file"
    )
  rescue => e
    Rails.logger.error "Error ingesting into GeoServer"
    Rails.logger.error "#{e.message}: #{e.inspect}"
    Rails.logger.error e.backtrace
  end

  def self.publish_to_geoblacklight(metadata:)
    solrdoc = JSON.parse(metadata.to_json)

    Blacklight.default_index.connection.add(solrdoc)
    puts "Committing changes to Solr"
    Blacklight.default_index.connection.commit
  end

  def self.hash_from_geoserver(id:)
    {
      gbl_resourceType_sm: get_layer_type("public:#{id}")
    }
  end

  # Validate the provided metadata against geoblacklight-schema-aardvark
  # @param [Hash] metadata
  def self.is_metadata_valid?(metadata)
    schema_path = Gem::Specification.find_by_name("geoblacklight").full_gem_path +
      "/schema/geoblacklight-schema-aardvark.json"
    schema = Pathname.new(schema_path)
    errors = JSONSchemer.schema(schema).validate(metadata.with_indifferent_access)
    if errors.count > 0
      puts "-- Aardvark validation errors: #{errors.map { |e| JSONSchemer::Errors.pretty(e) }}"
      false
    else
      true
    end
  end

  def self.get_layer_type(name)
    connection = Faraday.new(headers: {"Content-Type" => "application/json"}) do |conn|
      conn.request :authorization, :basic,
        ENV["GEOSERVER_ADMIN_USER"],
        ENV["GEOSERVER_ADMIN_PASSWORD"]
    end

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
    rtype = json["layer"]["defaultStyle"]["name"].titlecase

    ["#{rtype} data"]
  end

  def self.geoserver_references(metadata:)
    JSON.parse(metadata["dct_references_s"].gsub("http://localhost:8080", ENV["GEOSERVER_URL"])).merge(
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
