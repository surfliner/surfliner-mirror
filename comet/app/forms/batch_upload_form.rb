# frozen_string_literal: true

##
# @see https://github.com/samvera/valkyrie/wiki/ChangeSets-and-Dirty-Tracking
class BatchUploadForm < Valkyrie::ChangeSet
  property :source_file, multiple: false, required: true
  property :files_location, multiple: false, required: true

  def model_name
    self.class.model_name
  end

  # Required to back a form
  def to_key
    []
  end

  class << self
    def model_class
      ::BatchUpload
    end
  end
end
