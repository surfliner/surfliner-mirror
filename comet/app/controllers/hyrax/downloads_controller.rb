# frozen_string_literal: true

module Hyrax
  ##
  # Override Hyrax's default downloads controller with a custom one for comet
  class DownloadsController < ApplicationController
    before_action :authorize_download!
    def show
      file_set_id = params.require(:id)

      file = Hyrax.query_service.find_by(id: file_set_id)
      send_file_contents(file)
    end

    def authorize_download!
      authorize!(:download, params[:id])
    rescue CanCan::AccessDenied, Blacklight::Exceptions::RecordNotFound
      unauthorized_image = Rails.root.join("app", "assets", "images", "unauthorized.png")
      send_file unauthorized_image, status: :unauthorized
    end

    def send_file_contents(file_set)
      self.response_body = "abc"
    end
  end
end
