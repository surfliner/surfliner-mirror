# frozen_string_literal: true

module Hyrax
  ##
  # Override Hyrax's default downloads controller with a custom one for comet
  class DownloadsController < ApplicationController
    before_action :authorize_download!

    def show
      file_set_id = params.require(:id)
      file_set = Hyrax.query_service.find_by(id: file_set_id)
      send_file_contents(file_set)
    end

    private

    def authorize_download!
      authorize!(:download, params[:id])
    rescue CanCan::AccessDenied, Blacklight::Exceptions::RecordNotFound
      unauthorized_image = Rails.root.join("app", "assets", "images", "unauthorized.png")
      send_file unauthorized_image, status: :unauthorized
    end

    def send_file_contents(file_set)
      response.headers["Accept-Ranges"] = "bytes"
      self.status = 200
      file_metadata = find_file_metadata(file_set: file_set)
      file = Hyrax.storage_adapter.find_by(id: file_metadata.file_identifier)
      prepare_file_headers(metadata: file_metadata, file: file)
      file.rewind
      self.response_body = file.read
    end

    def prepare_file_headers(metadata:, file:)
      response.headers["Content-Disposition"] = "attachment; filename=#{metadata.original_filename}"
      response.headers["Content-Type"] = metadata.mime_type
      response.headers["Content-Length"] ||= (file.try(:size) || metadata.size.first)
      # Prevent Rack::ETag from calculating a digest over body
      response.headers["Last-Modified"] = metadata.updated_at.utc.strftime("%a, %d %b %Y %T GMT")
      self.content_type = metadata.mime_type
    end

    def content_options(file_metadata)
      {disposition: "attachment", type: file_metadata.mime_type, filename: file_metadata.original_filename}
    end

    def find_file_metadata(file_set:, use: :original_file)
      use = Hyrax::FileMetadata::Use.uri_for(use: use)
      Hyrax.query_service.find_by_alternate_identifier(alternate_identifier: file_set.file_ids.first)
    end
  end
end
