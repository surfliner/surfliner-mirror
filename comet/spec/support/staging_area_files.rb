##
# Mock fog/aws connection.
# @param [source_file] the destination file
# @param [s3_key] the key for the file in S3/Minio
def mock_fog_connection
  Fog.mock!
  fog_connection_options = {
    aws_access_key_id: "minio-access-key",
    aws_secret_access_key: "minio-secret-key",
    region: "us-east-1",
    endpoint: "http://minio:9000",
    path_style: true
  }
  Fog::Storage.new(provider: "AWS", **fog_connection_options)
end

##
# Upload file to S3/Minio with fog/aws.
# @param [fog_connection] Fog::Storage
# @param [source_file] the destination file
# @param [s3_key] the key for the file in S3/Minio
def staging_area_upload(fog_connection:, bucket:, s3_key:, source_file:)
  # Create the bucket if it doesn't exist
  begin
    fog_connection.head_bucket(bucket)
  rescue Excon::Error::NotFound
    puts "-- Creating buchet #{bucket}"
    fog_connection.directories.create(key: bucket)
  end

  fog_connection.directories.get(bucket).files
    .create(key: s3_key, body: File.open(source_file))
end
