
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
        row[CONFIG[:exhibit_type_key].to_sym] == CONFIG[:exhibit_class]
      end.first

      exhibit_params = {
        title: exhibit_row[CONFIG[:exhibit_title_key].to_sym],
        description: exhibit_row[CONFIG[:exhibit_description_key].to_sym]
      }

      exhibit = Spotlight::Exhibit.create(exhibit_params)
      objects = table.reject { |row| row == exhibit_row }.map do |row|
        resource = Spotlight::Resources::Upload.new(
          data: {
            'full_title_tesim' => row[CONFIG[:object_title_key].to_sym],
            'spotlight_upload_description_tesim' => row[CONFIG[:object_description_key].to_sym],
            'spotlight_upload_attribution_tesim' => row[CONFIG[:object_attribution_key].to_sym],
            'spotlight_upload_date_tesim' => row[CONFIG[:object_date_key].to_sym].to_s
          },
          exhibit: exhibit
        )

        file = Parse.get_binary_paths(Array(row[:files]), data).first
        logger.debug "Attaching #{file}"

        image = Spotlight::FeaturedImage.new
        image.image.store!(File.open(file))

        resource.upload = image
        resource.save_and_index
        resource
      end

      exhibit.resources = objects
      exhibit.save
      exhibit.reindex_later
    end
  end
end
