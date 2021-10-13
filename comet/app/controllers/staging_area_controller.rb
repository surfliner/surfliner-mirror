# frozen_string_literal: true

require "json"

class StagingAreaController < ApplicationController
  def index
    q = params["q"].nil? ? "" : params["q"]

    s3_handler = Rails.application.config.staging_area_s3_handler

    directories = {}.tap do |pro|
      s3_handler.get_paths(q).each do |path|
        pro[path.downcase] = {id: path, label: [path], value: path}
      end
    end.sort.to_h.values

    render json: directories.to_json
  end
end
