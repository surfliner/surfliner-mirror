##
# Upload file to S3/Minio with fog/aws.
# @param [source_file] the destination file
# @param [s3_key] the key for the file in S3/Minio
def staging_area_upload(bucket:, s3_key:, source_file:)
  Rails.application.config.staging_area_s3_connection
    .directories.get(bucket).files.create(key: s3_key, body: File.open(source_file))
end

##
# Download file from S3/Minio with S3 url
# @param [dest_file] the destination file
# @param [s3_url] the S3 file url
def download_s3_file(s3_url:, dest_file:)
  File.open(dest_file, "wb") do |f|
    URI.parse(s3_url).open do |uri|
      f.write(uri.read)
    end
  end
end
