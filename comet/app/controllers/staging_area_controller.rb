# frozen_string_literal: true

require "json"
require "fog/aws"

class StagingAreaController < ApplicationController
  def index
    q = params["q"].nil? ? "" : params["q"]

    s3_handler = Rails.application.config.staging_area_s3_handler

    directories = {}.tap do |pro|
      s3_handler.list_files.each do |mf|
        path = mf.key
        path = path.rindex("/").nil? || !path.downcase.start_with?(q.downcase) ? "" : path[0..path.rindex("/")]
        pro[path.downcase] = {id: path, label: [path], value: path} unless pro.include?(path.downcase) || path.blank?
      end
    end.sort.to_h.values

    render json: directories.to_json
  end
end
