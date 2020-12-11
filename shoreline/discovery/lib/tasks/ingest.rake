# frozen_string_literal: true

require 'csv'

namespace :shoreline do
  desc 'ingest a CSV of objects into GeoServer and GeoBlacklight'
  task :ingest, [:csv_path] => :environment do |_t, args|
    file_root = ENV['SHORELINE_FILE_ROOT']

    Importer.csv(csv: args[:csv_path], file_root: file_root)
  rescue StandardError => e
    puts e.message
  end
end
