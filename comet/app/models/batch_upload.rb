# frozen_string_literal: true

class BatchUpload < Struct.new(:source_file, :files_location)
  # Required to back a form
  def persisted?
    false
  end
end
