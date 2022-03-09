# frozen_string_literal: true

##
# @see bin/ingest and doc/deploy.md
module Importer
  XPATHS = {
    dc_description_s: "//xmlns:identificationInfo//xmlns:abstract/gco:CharacterString",
    dc_format_s: "//xmlns:MD_Format/xmlns:name/gco:CharacterString",
    dc_title_s: "//xmlns:title/gco:CharacterString"
  }.freeze

  XPATHS_MULTIVALUE = {
    dc_creator_sm: "//xmlns:identificationInfo//xmlns:role[xmlns:CI_RoleCode[@codeListValue='originator']]/preceding-sibling::xmlns:organisationName/gco:CharacterString",
    dc_publisher_sm: "//xmlns:identificationInfo//xmlns:role[xmlns:CI_RoleCode[@codeListValue='publisher']]/preceding-sibling::xmlns:organisationName/gco:CharacterString",
    dc_subject_sm: "//xmlns:MD_Keywords[xmlns:type/xmlns:MD_KeywordTypeCode[@codeListValue='theme']]/xmlns:keyword/gco:CharacterString",
    dct_isPartOf_sm: "//xmlns:identificationInfo//xmlns:collectiveTitle/gco:CharacterString",
    dct_spatial_sm: "//xmlns:MD_Keywords[xmlns:type/xmlns:MD_KeywordTypeCode[@codeListValue='place']]/xmlns:keyword/gco:CharacterString"
  }.freeze
  # rubocop:enable Layout/LineLength

  EXTRA_FIELDS = {
    geoblacklight_version: "1.0"
  }.freeze

  REFERENCES = {
    wfs: "http://#{ENV["GEOSERVER_HOST"]}:#{ENV["GEOSERVER_PORT"]}/geoserver/wfs",
    wms: "http://#{ENV["GEOSERVER_HOST"]}:#{ENV["GEOSERVER_PORT"]}/geoserver/wms"
  }

  BOUNDS = {
    east: "//xmlns:eastBoundLongitude/gco:Decimal",
    north: "//xmlns:northBoundLatitude/gco:Decimal",
    south: "//xmlns:southBoundLatitude/gco:Decimal",
    west: "//xmlns:westBoundLongitude/gco:Decimal"
  }.freeze

  def self.ingest_csv(csv:, file_root:)
    table = CSV.table(csv, encoding: "UTF-8")

    table.each do |row|
      if row[:zipfilename].nil?
        warn "missing field zipfilename"
        warn row.inspect
        exit 1
      end
      zipfile = Pathname.new(file_root).join(row[:zipfilename]).to_s
      puts "-- Processing #{zipfile}"

      publish_to_geoserver(file_path: zipfile)

      metadata = assemble_attributes(row: row, file: zipfile)
      publish_to_geoblacklight(metadata: metadata)
    end
  end

  def self.publish_to_geoserver(file_path:)
    conn = Geoserver::Publish::Connection.new(
      "url" => "http://#{ENV["GEOSERVER_HOST"]}:#{ENV["GEOSERVER_PORT"]}/geoserver/rest",
      "user" => ENV["GEOSERVER_ADMIN_USER"],
      "password" => ENV["GEOSERVER_ADMIN_PASSWORD"]
    )

    file = File.read(file_path)
    file_id = File.basename(file_path, File.extname(file_path))
    workspace = ENV.fetch("GEOSERVER_WORKSPACE", "public")

    puts "-- Publishing to GeoServer as #{file_id}"

    Geoserver::Publish.create_workspace(workspace_name: workspace, connection: conn)
    Geoserver::Publish::DataStore.new(conn).upload(workspace_name: workspace, data_store_name: file_id, file: file)
  end

  def self.assemble_attributes(row:, file:)
    initial = hash_from_xml(file: file)

    initial
      .merge(hash_from_csv(row: row))
      .merge(hash_from_geoserver(id: initial[:layer_slug_s]))
      .merge(EXTRA_FIELDS).reject { |_k, v| v.blank? }
  end

  def self.publish_to_geoblacklight(metadata:)
    solrdoc = JSON.parse(metadata.to_json)

    Blacklight.default_index.connection.add(solrdoc)
    puts "Committing changes to Solr"
    Blacklight.default_index.connection.commit
  end

  def self.hash_from_csv(row:)
    values = {
      dc_rights_s: row[:access] || "Public",
      dct_provenance_s: row[:provenance]
    }

    if row[:references].present?
      refs = transform_reference_uris(
        REFERENCES.merge(parse_references(row[:references]))
      )

      values.merge({dct_references_s: refs.to_json})
    else
      values
    end
  end

  def self.hash_from_geoserver(id:)
    {
      layer_geom_type_s: get_layer_type("public:#{id}")
    }
  end

  def self.hash_from_xml(file:)
    Dir.mktmpdir do |dir|
      puts "Unzipping #{file} to #{dir}"

      # -j: flatten directory structure in `dest'
      # -o: overwrite existing files in `dest'
      system "unzip", "-qq", "-j", "-o", file, "-d", dir

      iso = Dir.entries(dir).find do |f|
        /.*-iso\.xml$/i.match(f)
      end

      xml = Nokogiri::XML(File.open("#{dir}/#{iso}"))

      id = File.basename(Dir.glob("*.shp", base: dir)[0], ".shp")
      xml_attrs(id: id, xml: xml)
    end
  rescue ArgumentError => e
    warn "No ISO metadata found in #{file}"
    raise e
  end

  def self.xml_attrs(options)
    attributes = {}

    id = options[:id]
    attributes[:dc_identifier_s] = "public:#{id}"
    attributes[:layer_slug_s] = id.to_s
    attributes[:layer_id_s] = "public:#{id}"

    attributes[:solr_year_i] = year(options[:xml])
    attributes[:solr_geom] = envelope(options[:xml])

    XPATHS.each do |k, v|
      attributes[k] = CGI.unescapeHTML(options[:xml].xpath(v).first.children.first.to_s)
    end

    XPATHS_MULTIVALUE.each do |k, v|
      attributes[k] = options[:xml].xpath(v).map(&:children).flatten.map(&:to_s).map { |s| CGI.unescapeHTML(s) }
    end

    attributes
  rescue NoMethodError => e
    warn "Could not extract #{k} from #{iso}"
    raise e
  end

  def self.get_layer_type(name)
    connection = Faraday.new(headers: {"Content-Type" => "application/json"})
    connection.basic_auth(
      ENV["GEOSERVER_ADMIN_USER"],
      ENV["GEOSERVER_ADMIN_PASSWORD"]
    )

    url = "http://#{ENV["GEOSERVER_HOST"]}:#{ENV["GEOSERVER_PORT"]}/geoserver/rest/layers/#{name}.json"

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

  def self.year(xml)
    xml.xpath("substring(//xmlns:MD_DataIdentification/xmlns:citation//gco:Date, 1, 4)")
  end

  def self.envelope(xml)
    coords = %i[west east north south].map do |dir|
      xml.xpath(BOUNDS[dir]).map(&:children).flatten.map(&:to_s).first
    end

    "ENVELOPE(#{coords.join(",")})"
  end

  # @param [String] references
  # @return [Hash]
  def self.parse_references(references)
    references.split("|").map do |ref|
      keyvalue = ref.split("^")
      {keyvalue[0].to_sym => keyvalue[1]}
    end.reduce(&:merge)
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
