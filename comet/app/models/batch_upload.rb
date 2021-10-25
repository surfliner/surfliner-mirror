# frozen_string_literal: true

class BatchUpload < ApplicationRecord
  self.table_name = "batch_uploads"

  attr_accessor :source_file, :files_location

  # Required to back a form
  def persisted?
    false
  end
end
