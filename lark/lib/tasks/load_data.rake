# frozen_string_literal: true

require_relative "../../config/environment"

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
  parser = Lark::RecordParsers::JsonParser.new
  parser.parse(record)
end
