# frozen_string_literal: true

require "json"
require "fog/aws"

class StagingController < ApplicationController
  def index
    q = params["q"].nil? ? "" : params["q"]

    fog_connection_options = Rails.application.config.fog_connection_options
    staging_bucket = ENV.fetch("REPOSITORY_S3_BUCKET")
    s3_handler = StagingS3Handler.new(fog_connection_options: fog_connection_options,
      bucket: staging_bucket,
      prefix: "")

    directories = {}.tap do |pro|
      s3_handler.list_files.each do |mf|
        path = mf.key
        path = path.rindex("/").nil? || !path.downcase.start_with?(q.downcase) ? "" : path[0..path.rindex("/")]
        pro[path] = {id: path, label: [path], value: path} unless pro.include?(path) || path.blank?
      end
    end.sort.to_h.values

    render json: directories.to_json
  end
end
