# frozen_string_literal: true

##
# A S3/Minio staging handler with fog/aws
# for batch ingest directory lookup and file download
class StagingAreaS3Handler
  attr_accessor :connection, :bucket, :prefix, :bucket_name

  ##
  # Constructor
  # @param connection[Fog::Storage]
  # @param bucket[String] - the bucket name
  # @param prefix[String] - the path in the bucket
  def initialize(connection:, bucket:, prefix:)
    @prefix = prefix
    @connection = connection
    @bucket_name = bucket
    @bucket = @connection.directories.get(bucket, prefix: prefix)
  end

  ##
  # List files name in the bucket with prefix
  # @param prefix - the prefix of the files
  # return[[String]] - file names
  def get_filenames(prefix)
    @connection.directories.get(@bucket_name, prefix: prefix)
      .files.map { |mf| mf.key.sub(prefix, "") }
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

  ##
  # List the paths in the bucket
  # @q [String] - search keyword
  def get_paths(q)
    [].tap do |pro|
      list_files.each do |mf|
        path = mf.key
        path = path.rindex("/").nil? || !path.downcase.start_with?(q.downcase) ? "" : path[0..path.rindex("/")]
        pro << path unless pro.include?(path) || path.blank?
      end
    end
  end
end
