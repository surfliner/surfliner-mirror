# frozen_string_literal: true

class BatchUpload < ActiveFedora::Base
  attr_accessor :source_file, :files_location
  validates :source_file, :files_location, presence: true

  def create_or_update
    raise "This is a read only record"
  end
end
