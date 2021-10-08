# frozen_string_literal: true

##
# A S3/Minio staging handler with fog/aws
# for batch ingest directory lookup and file download
class StagingAreaS3Handler
  attr_accessor :fog_storage, :bucket, :prefix

  ##
  # Constructor
  # @param fog_connection_options[Hash]
  # @param bucket[String] - the bucket name
  # @param prefix[String] - the path in the bucket
  def initialize(fog_connection_options:, bucket:, prefix:)
    @prefix = prefix
    @fog_storage = Fog::Storage.new(provider: "AWS", **fog_connection_options)
    @bucket = @fog_storage.directories.get(bucket, prefix: prefix)
  end

  ##
  # List files in the bucket
  # return[[Fog::Storage::AWS::File]]
  def list_files
    @bucket.files
  end

  ##
  # Create file url for S3 file by key
  # @param key[String]
  # return [String] url expired in a week
  def file_url(key)
    @bucket.files.get(key).url(Time.zone.now + 7.day.to_i)
  end

  ##
  # Copy file from S3/Minio to local disk storage
  # @param s3_key[String]
  # @param dest_file[String] - the path to local storage
  def copy_file(s3_key, dest_file)
    dir = File.dirname(dest_file)
    unless File.directory?(dir)
      FileUtils.mkdir_p(dir)
    end

    File.open(dest_file, "wb") do |f|
      @bucket.files.get(s3_key) do |chunk|
        f.write chunk
      end
    end
  end
end
