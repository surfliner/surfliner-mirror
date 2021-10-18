##
# @api public
#
# Batch upload file from staging area, similar to Hyrax::UploadedFile for CarrierWave
class BatchUploadFile
  attr_reader :user, :file
  attr_accessor :file_set_uri

  ##
  # @param user [User] - the depositor
  # file [StagingAreaFile] - the staging area file to upload
  def initialize(user:, file:)
    @user = user
    @file = file
  end

  ##
  # Function that expected from Hyrax::WorkUploadsHandler to set the FileSet
  # @param file_set [Hyrax::FileSet]
  def add_file_set!(file_set)
    @file_set_uri = file_set.id
  end
end
