# frozen_string_literal: true

$stdout.sync = true

require "json"

namespace :shoreline do
  desc "ingest an Aardvark JSON file into GeoBlacklight"
  task :ingest_aardvark, [:json_path] => :environment do |_t, args|
    blob = JSON.parse(File.read(args[:json_path]))

    Importer.ingest(metadata: blob)
  rescue => e
    warn "--- ERROR: #{e.message}"
    warn "--- ERROR: #{e.backtrace}"
    exit 1
  end
end
