# frozen_string_literal: true

module Importer::CLI
  def self.run(options)
    logger = make_logger(output: options[:logfile], level: options[:verbosity])

    # For each argument passed to --metadata, if it's a file with the
    # correct extension, add it to the array, otherwise drill down and add
    # each file within to the array
    meta = Parse.find_paths(options[:metadata], '.csv')

    logger.debug 'Metadata inputs:'
    meta.each { |m| logger.debug m }

    if options[:data].blank?
      logger.warn 'No data sources specified.'
    else
      logger.debug 'Data inputs:'
      options[:data].each { |d| logger.debug d }
    end

    ::Importer::Exhibit.import(
      meta: meta,
      data: options[:data],
      logger: logger
    )
  end

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
end
