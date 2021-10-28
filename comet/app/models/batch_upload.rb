# frozen_string_literal: true

class BatchUpload < ApplicationRecord
  self.table_name = "batch_uploads"

  attr_accessor :source_file, :files_location

  belongs_to :user

  # Required to back a form
  def persisted?
    false
  end
end
