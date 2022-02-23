# frozen_string_literal: true

require "csv"

namespace :shoreline do
  desc "ingest a CSV of objects into GeoServer and GeoBlacklight"
  task :ingest, [:csv_path] => :environment do |_t, args|
    file_root = ENV["SHORELINE_FILE_ROOT"]

    puts "-- Ingesting files from #{file_root} with metadata located at #{args[:csv_path]}"

    Importer.ingest_csv(csv: args[:csv_path], file_root: file_root)
  rescue => e
    warn "--- ERROR: #{e.message}"
    exit 1
  end
end
