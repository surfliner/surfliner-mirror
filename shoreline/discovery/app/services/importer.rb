# frozen_string_literal: true

##
# @see bin/ingest and doc/deploy.md
module Importer
  # rubocop:disable Layout/LineLength
  XPATHS = {
    dc_description_s: '//xmlns:identificationInfo//xmlns:abstract/gco:CharacterString',
    dc_format_s: '//xmlns:MD_Format/xmlns:name/gco:CharacterString',
    dc_title_s: '//xmlns:title/gco:CharacterString'
  }.freeze

  XPATHS_MULTIVALUE = {
    dc_creator_sm: "//xmlns:identificationInfo//xmlns:role[xmlns:CI_RoleCode[@codeListValue='originator']]/preceding-sibling::xmlns:organisationName/gco:CharacterString",
    dc_publisher_sm: "//xmlns:identificationInfo//xmlns:role[xmlns:CI_RoleCode[@codeListValue='publisher']]/preceding-sibling::xmlns:organisationName/gco:CharacterString",
    dc_subject_sm: "//xmlns:MD_Keywords[xmlns:type/xmlns:MD_KeywordTypeCode[@codeListValue='theme']]/xmlns:keyword/gco:CharacterString",
    dct_isPartOf_sm: '//xmlns:identificationInfo//xmlns:collectiveTitle/gco:CharacterString',
    dct_spatial_sm: "//xmlns:MD_Keywords[xmlns:type/xmlns:MD_KeywordTypeCode[@codeListValue='place']]/xmlns:keyword/gco:CharacterString"
  }.freeze

  EXTRA_FIELDS = {
    dct_provenance_s: ENV.fetch('SHORELINE_PROVENANCE', ''),
    dct_references_s: "{\"http://www.opengis.net/def/serviceType/ogc/wfs\":\"http://#{ENV['GEOSERVER_HOST']}:#{ENV['GEOSERVER_PORT']}/geoserver/wfs\", \"http://www.opengis.net/def/serviceType/ogc/wms\":\"http://#{ENV['GEOSERVER_HOST']}:#{ENV['GEOSERVER_PORT']}/geoserver/wms\"}",
    geoblacklight_version: '1.0'
  }.freeze
  # rubocop:enable Layout/LineLength

  BOUNDS = {
    east: '//xmlns:eastBoundLongitude/gco:Decimal',
    north: '//xmlns:northBoundLatitude/gco:Decimal',
    south: '//xmlns:southBoundLatitude/gco:Decimal',
    west: '//xmlns:westBoundLongitude/gco:Decimal'
  }.freeze

  def self.csv(csv:, file_root:)
    table = CSV.table(csv, encoding: 'UTF-8')

    table.each do |row|
      if row[:zipfilename].nil?
        warn 'missing field zipfilename'
        warn row.inspect
        exit 1
      end

      zipfile = Pathname.new(file_root).join(row[:zipfilename]).to_s

      geoserver(file_path: zipfile)
      run(csv_row: row, file_path: zipfile)
    end
  end

  def self.geoserver(file_path:)
    conn = Geoserver::Publish::Connection.new(
      # Using internal hostname to avoid the nginx ingress, which limits filesize
      'url' => "http://#{ENV['GEOSERVER_INTERNAL_HOST']}:#{ENV['GEOSERVER_PORT']}/geoserver/rest",
      'user' => ENV['GEOSERVER_USER'],
      'password' => ENV['GEOSERVER_PASSWORD']
    )

    file = File.read(file_path)
    file_id = File.basename(file_path, File.extname(file_path))
    workspace = ENV.fetch('GEOSERVER_WORKSPACE', 'public')

    Geoserver::Publish.create_workspace(workspace_name: workspace, connection: conn)
    Geoserver::Publish::DataStore.new(conn).upload(workspace_name: workspace, data_store_name: file_id, file: file)
  end

  def self.run(csv_row:, file_path:)
    metadata = hash_from_xml(file_path)
               .merge(hash_from_csv(csv_row))
               .merge(EXTRA_FIELDS).reject { |_k, v| v.blank? }

    solrdoc = JSON.parse(metadata.to_json)

    Blacklight.default_index.connection.add(solrdoc)
    puts 'Committing changes to Solr'
    Blacklight.default_index.connection.commit
  end

  def self.hash_from_csv(row)
    {
      dc_rights_s: row[:access] || 'Public'
    }
  end

  def self.hash_from_xml(file)
    Dir.mktmpdir do |dir|
      puts "Unzipping #{file} to #{dir}"

      # -j: flatten directory structure in `dest'
      # -o: overwrite existing files in `dest'
      system 'unzip', '-qq', '-j', '-o', file, '-d', dir

      iso = Dir.entries(dir).select do |f|
        /.*-iso\.xml$/i.match(f)
      end.first

      xml = Nokogiri::XML(File.open("#{dir}/#{iso}"))

      id = File.basename(Dir.glob('*.shp', base: dir)[0], '.shp')
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
    attributes[:layer_geom_type_s] = type("public:#{id}")
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

  def self.type(name)
    connection = Faraday.new(headers: { 'Content-Type' => 'application/json' })
    connection.basic_auth(
      ENV['GEOSERVER_USER'],
      ENV['GEOSERVER_PASSWORD']
    )

    url = "http://#{ENV['GEOSERVER_INTERNAL_HOST']}:#{ENV['GEOSERVER_PORT']}/geoserver/rest/layers/#{name}.json"

    json = JSON.parse(connection.get(url).body)
    json['layer']['defaultStyle']['name'].titlecase
  end

  def self.year(xml)
    xml.xpath('substring(//xmlns:MD_DataIdentification/xmlns:citation//gco:Date, 1, 4)')
  end

  def self.envelope(xml)
    coords = %i[west east north south].map do |dir|
      xml.xpath(BOUNDS[dir]).map(&:children).flatten.map(&:to_s).first
    end

    "ENVELOPE(#{coords.join(',')})"
  end
end
