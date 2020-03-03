# frozen_string_literal: true

##
# @see bin/ingest and doc/deploy.md
module Importer
  XPATHS = {
    # rubocop:disable Layout/LineLength
    dc_description_s: '//xmlns:identificationInfo//xmlns:abstract/gco:CharacterString',
    dc_format_s: '//xmlns:MD_Format/xmlns:name/gco:CharacterString',
    dc_title_s: '//xmlns:title/gco:CharacterString'
    # rubocop:enable Layout/LineLength
  }.freeze

  XPATHS_MULTIVALUE = {
    # rubocop:disable Layout/LineLength
    dc_creator_sm: "//xmlns:identificationInfo//xmlns:role[xmlns:CI_RoleCode[@codeListValue='originator']]/preceding-sibling::xmlns:organisationName/gco:CharacterString",
    dc_publisher_sm: "//xmlns:identificationInfo//xmlns:role[xmlns:CI_RoleCode[@codeListValue='publisher']]/preceding-sibling::xmlns:organisationName/gco:CharacterString",
    dc_subject_sm: "//xmlns:MD_Keywords[xmlns:type/xmlns:MD_KeywordTypeCode[@codeListValue='theme']]/xmlns:keyword/gco:CharacterString",
    dct_isPartOf_sm: '//xmlns:identificationInfo//xmlns:collectiveTitle/gco:CharacterString',
    dct_spatial_sm: "//xmlns:MD_Keywords[xmlns:type/xmlns:MD_KeywordTypeCode[@codeListValue='place']]/xmlns:keyword/gco:CharacterString"
    # rubocop:enable Layout/LineLength
  }.freeze

  ID = SecureRandom.uuid.to_s

  EXTRA_FIELDS = {
    dc_identifier_s: ID,
    dc_rights_s: ENV.fetch('SHORELINE_ACCESS', 'Public'),
    dct_provenance_s: ENV.fetch('SHORELINE_PROVENANCE', ''),
    geoblacklight_version: '1.0',
    layer_slug_s: ID
  }.freeze

  BOUNDS = {
    east: '//xmlns:eastBoundLongitude/gco:Decimal',
    north: '//xmlns:northBoundLatitude/gco:Decimal',
    south: '//xmlns:southBoundLatitude/gco:Decimal',
    west: '//xmlns:westBoundLongitude/gco:Decimal'
  }.freeze

  def self.make_logger(output:, level: 'INFO')
    logger = Logger.new(output)
    logger.level = begin
                     "Logger::#{level.upcase}".constantize
                   rescue NameError
                     logger.warn "#{level} isn't a valid log level. "\
                                 'Defaulting to INFO.'
                     Logger::INFO
                   end

    ActiveSupport::Deprecation.behavior = lambda do |message, backtrace|
      logger.warn message
      logger.warn backtrace
    end

    # For deprecation warnings from gems
    $stderr.reopen(output, 'a') if output.is_a? Pathname

    logger
  end

  def self.run(options)
    logger = make_logger(output: options[:logfile], level: options[:verbosity])
    metadata = JSON.parse(
      extract(zipfile: options[:file], logger: logger).to_json
    )

    logger.info metadata

    Blacklight.default_index.connection.add(metadata)
    logger.info 'Committing changes to Solr'
    Blacklight.default_index.connection.commit
  end

  def self.extract(options)
    Dir.mktmpdir do |dir|
      options[:logger].info "Unzipping #{options[:zipfile]} to #{dir}"

      # -j: flatten directory structure in `dest'
      # -o: overwrite existing files in `dest'
      system 'unzip', '-qq', '-j', '-o', options[:zipfile], '-d', dir

      iso = Dir.glob('*iso19139.xml', base: dir)[0]
      xml = Nokogiri::XML(File.open("#{dir}/#{iso}"))

      makeattrs(xml: xml, logger: options[:logger])
    end
  rescue ArgumentError => e
    options[:logger].error "No ISO metadata found in #{options[:zipfile]}"
    raise e
  end

  def self.makeattrs(options)
    attributes = {}

    # rubocop:disable Layout/LineLength
    XPATHS.each do |k, v|
      attributes[k] = CGI.unescapeHTML(options[:xml].xpath(v).first.children.first.to_s)
    end

    XPATHS_MULTIVALUE.each do |k, v|
      attributes[k] = options[:xml].xpath(v).map(&:children).flatten.map(&:to_s).map { |s| CGI.unescapeHTML(s) }
    end

    attributes[:solr_year_i] = options[:xml].xpath('substring(//xmlns:identificationInfo//gml:timePosition, 1, 4)')
    # rubocop:enable Layout/LineLength

    coords = %i[west east north south].map do |dir|
      options[:xml].xpath(BOUNDS[dir]).map(&:children).flatten.map(&:to_s).first
    end
    attributes[:solr_geom] = "ENVELOPE(#{coords.join(',')})"

    attributes.merge(EXTRA_FIELDS).reject { |_k, v| v.blank? }
  rescue NoMethodError => e
    options[:logger].error "Could not extract #{k} from #{iso}"
    raise e
  end
end
