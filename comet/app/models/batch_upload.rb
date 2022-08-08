# frozen_string_literal: true

class BatchUpload < ApplicationRecord
  self.table_name = "batch_uploads"

  attr_accessor :source_file, :files_location

  belongs_to :user

  def self.ingest_options
    %w[metadata+files files-only geodata]
  end

  def self.files_only_ingest
    "files-only"
  end

  def self.geodata_ingest
    "geodata"
  end

  # Required to back a form
  def persisted?
    false
  end
end
