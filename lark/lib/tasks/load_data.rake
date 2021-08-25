# frozen_string_literal: true

require_relative "../../config/environment"
require_relative "../../app/transactions/lark/transactions/create_authority"
require_relative "../lark/record_parsers/json_parser"

namespace :lark do
  desc "load dummy records"
  task seed: :environment do
    import_data(
      YAML.load_file(File.expand_path("../../config/dummy_record.yml", __dir__))
    )
  end
end

def import_data(records)
  event_stream = Lark.config.event_stream
  records.each do |re|
    Lark::Transactions::CreateAuthority
      .new(event_stream: event_stream)
      .call(attributes: parser(re.to_json))
      .value!
  end
end

def parser(record)
  parser = Lark::RecordParsers::JSONParser.new
  parser.parse(record)
end
