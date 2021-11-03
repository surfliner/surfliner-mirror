# frozen_string_literal: true

namespace :comet do
  namespace :staging_area do
    desc "Initiate S3/Minio staging area with example project files"
    task upload_files: :environment do
      root_dir = Rails.root.join("spec", "fixtures", "staging_area")

      puts "--Uploading example files from #{root_dir} to S3/Minio staging area ..."

      upload_files(list_files(root_dir))
    end
  end
end

def upload_files(files)
  files.each do |f|
    project_folder = Pathname.new(f).dirname.each_filename.to_a.last
    s3_key = "#{project_folder}/#{File.basename(f)}"

    puts "--Uploading file #{f} to S3/Minio with key #{s3_key} ..."

    Rails.application.config.staging_area_s3_connection
      .directories.get(ENV.fetch("STAGING_AREA_S3_BUCKET", "comet-staging-area-#{Rails.env}")).files
      .create(key: s3_key, body: File.open(f))
  end
end

def list_files(dir)
  Dir.glob("#{dir}/**/*").select { |f| File.file?(f) }
end
