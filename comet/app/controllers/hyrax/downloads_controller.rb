# frozen_string_literal: true

module Hyrax
  ##
  # Override Hyrax's default downloads controller with a custom one for comet
  class DownloadsController < ApplicationController
    EXPIRES_IN = 10.minutes.to_i # S3 presigned URL TTL

    before_action :authorize_download!

    def show
      file_set = Hyrax.query_service.find_by(id: params.require(:id))
      redirect_to_presigned(file_set: file_set, use: use)
    end

    private

    def authorize_download!
      authorize!(:download, params[:id])
    rescue CanCan::AccessDenied, Blacklight::Exceptions::RecordNotFound
      unauthorized_image = Rails.root.join("app", "assets", "images", "unauthorized.png")
      send_file unauthorized_image, status: :unauthorized
    end

    def disposition
      case params["disposition"]
      when "inline"
        "inline"
      else
        ActiveModel::Type::Boolean.new.cast(params["inline"]) ? "inline" : "attachment"
      end
    end

    def find_file_metadata(file_set:, use: :original_file)
      use = Hyrax::FileMetadata::Use.uri_for(use: use)

      results = Hyrax.custom_queries.find_many_file_metadata_by_use(resource: file_set, use: use)

      results.first || raise(Hyrax::ObjectNotFoundError)
    end

    def redirect_to_presigned(file_set:, use: :original_file)
      file_metadata = find_file_metadata(file_set: file_set, use: use)

      url = PresignedUrl.url(
        id: file_metadata.file_identifier,
        expires_in: EXPIRES_IN,
        host: s3_endpoint_override,
        response_content_type: file_metadata.mime_type,
        response_content_disposition: ContentDisposition.format(disposition: disposition, filename: file_metadata.original_filename)
      )

      redirect_to(url)
    end

    def s3_endpoint_override
      return nil if use_internal_endpoint?

      ENV["MINIO_EXTERNAL_ENDPOINT"].presence
    end

    def use_internal_endpoint?
      ActiveModel::Type::Boolean.new.cast(params["use_internal_endpoint"])
    end

    ##
    # @return [Symbol]
    def use
      params.fetch(:use, :original_file).to_sym
    end

    private

    class PresignedUrl
      def self.url(id:, adapter: Hyrax.storage_adapter, **opts)
        new(id: id, adapter: adapter).url(**opts)
      end

      def initialize(id:, adapter: Hyrax.storage_adapter)
        @adapter = adapter
        @id = id
      end

      def shrine_id
        @adapter.send(:shrine_id_for, @id)
      end

      def url(**opts)
        host = opts.delete(:host)
        url = @adapter.shrine.url(shrine_id, **opts)
        url.host = host if host.present?
        url
      end
    end
  end
end
