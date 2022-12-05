# frozen_string_literal: true

namespace :shoreline do
  namespace :staging_area do
    desc "Initiate S3/Minio staging area with example project files"
    task upload_shapefiles: :environment do
      root_dir = Rails.root.join("spec", "fixtures", "shapefiles")

      puts "--Uploading example files from #{root_dir} to S3/Minio staging area ..."

      upload_files(list_files(root_dir))

      root_dir = Rails.root.join("spec", "fixtures", "geodata")
      puts "--Uploading UCSB example shapefiles from #{root_dir} to S3/Minio staging area ..."

      upload_files(list_files(root_dir), "shapefiles")
    end
  end
end

def upload_files(files, s3_key_prefix = nil)
  begin_time = Time.now
  sleep 2.seconds and puts "Waiting on S3/Minio connection ..." until Time.now > (begin_time + 5 * 60) || Rails.application.config.staging_area_s3_connection

  files.each do |f|
    s3_key_prefix = Pathname.new(f).dirname.each_filename.to_a.last if s3_key_prefix.nil?
    s3_key = "#{s3_key_prefix}/#{File.basename(f)}"

    puts "--Uploading file #{f} to S3/Minio with key #{s3_key} ..."

    Rails.application.config.staging_area_s3_connection
      .directories.get(ENV.fetch("STAGING_AREA_S3_BUCKET", "shoreline-staging-area-#{Rails.env}")).files
      .create(key: s3_key, body: File.open(f))
  end
end

def list_files(dir)
  Dir.glob("#{dir}/**/*").select { |f| File.file?(f) }
end
