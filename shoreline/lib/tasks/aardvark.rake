# frozen_string_literal: true

$stdout.sync = true

require "json"

namespace :shoreline do
  desc "Convert GBL 1.0 to Aardvark"
  task :convert_to_aardvark, [:json_path] => :environment do |_t, args|
    json = JSON.parse(File.read(args[:json_path]))

    puts Shoreline::Aardvark.convert(json).to_json
  end
end
