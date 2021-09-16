# frozen_string_literal: true

##
# @see https://github.com/samvera/valkyrie/wiki/ChangeSets-and-Dirty-Tracking
class BatchUploadForm < Valkyrie::ChangeSet
  property :source_file, multiple: false, required: true
  property :files_location, multiple: false, required: true

  class << self
    def model_class
      ::BatchUpload
    end
  end
end
