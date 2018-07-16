# frozen_string_literal: true

require 'erb'
require 'ostruct'
require 'csv'

module Importer::Exhibit
  CONFIG = YAML.safe_load(
    ERB.new(File.read(Rails.root.join('config', 'import.yml'))).result
  ).with_indifferent_access.freeze

  # @param [Array<String>] meta
  # @param [Array<String>] data
  # @param [Logger] log
  # @return [Integer] The number of records ingested
  def self.import(meta:, data:, logger: Logger.new(STDOUT))
    meta.each do |m|
      table = ::CSV.table(m, encoding: 'UTF-8')

      exhibit_row = table.select do |row|
        # byebug
        row[CONFIG[:exhibit_type_key].to_sym] == CONFIG[:exhibit_class]
      end.first

      # byebug

      exhibit_params = {
        title: exhibit_row[CONFIG[:exhibit_title_key].to_sym],
        description: exhibit_row[CONFIG[:exhibit_description_key].to_sym]
      }

      exhibit = Spotlight::Exhibit.create(exhibit_params)

      objects = table.reject { |row| row == exhibit_row }.map do |row|
        file = Parse.get_binary_paths(Array(row[:files]), data).first

        {
          attribution: row[CONFIG[:object_attribution_key].to_sym],
          base64: Base64.encode64(File.read(file)).delete("\n"),
          date: row[CONFIG[:object_date_key].to_sym],
          description: row[CONFIG[:object_description_key].to_sym],
          filename: file,
          mime: MIME::Types.type_for(file).first.content_type,
          title: row[CONFIG[:object_title_key].to_sym]
        }
      end

      erb_vars = OpenStruct.new(
        created: Time.zone.now.strftime('%FT%T.%LZ'),
        exhibit: exhibit_params,
        objects: objects
      ).instance_eval { binding }

      json = JSON.parse(
        ERB.new(
          File.read(Rails.root.join('lib', 'importer', 'data.json.erb'))
        ).result(erb_vars)
      )

      # File.open(Rails.root.join('tmp', 'ex.json'), 'a') do |f|
      #   f.write json
      # end

      exhibit.import(json)
      exhibit.save
      # exhibit.reindex_later
    end
  end
end
