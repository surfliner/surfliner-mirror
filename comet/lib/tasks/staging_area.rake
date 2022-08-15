# frozen_string_literal: true

namespace :comet do
  namespace :staging_area do
    desc "Initiate S3/Minio staging area with example project files"
    task upload_files: :environment do
      root_dir = Rails.root.join("spec", "fixtures", "staging_area")

      puts "--Uploading example files from #{root_dir} to S3/Minio staging area ..."

      upload_files(list_files(root_dir))

      root_dir = Rails.root.join("spec", "fixtures", "geodata")
      puts "--Uploading ucsb example geospatial dtata files from #{root_dir} to S3/Minio staging area ..."

      upload_files(list_files(root_dir), "geodata")
    end
  end
end

def upload_files(files, s3_key_prefix = nil)
  files.each do |f|
    s3_key_prefix = Pathname.new(f).dirname.each_filename.to_a.last if s3_key_prefix.nil?
    s3_key = "#{s3_key_prefix}/#{File.basename(f)}"

    puts "--Uploading file #{f} to S3/Minio with key #{s3_key} ..."

    Rails.application.config.staging_area_s3_connection
      .directories.get(ENV.fetch("STAGING_AREA_S3_BUCKET", "comet-staging-area-#{Rails.env}")).files
      .create(key: s3_key, body: File.open(f))
  end
end

def list_files(dir)
  Dir.glob("#{dir}/**/*").select { |f| File.file?(f) }
end
