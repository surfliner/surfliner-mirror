# frozen_string_literal: true

module Hyrax
  class BatchUploadsController < ApplicationController
    with_themed_layout "dashboard"
    before_action :authenticate_user!

    def new
      @batch_upload = BatchUpload.new
      @form = BatchUploadForm.new(@batch_upload)
    end

    def create
      permitted = params.require(:batch_upload).permit(:source_file, :files_location)
      if Rails.application.config.staging_area_s3_enabled
        permitted = permitted.merge(files_location: params.require(:files_location))
      end

      Hyrax.logger.debug(permitted)

      source_path = permitted[:source_file].path

      ::TabularParser
        .for(content_type: permitted[:source_file].content_type)
        .parse(source_path)
        .each_with_index do |row, i|
        ##
        # TODO: Convert data, build object metadata and ingest files
      end

      redirect_to(new_batch_upload_path,
        notice: t("hyrax.dashboard.batch_uploads.submission_success"))
    end
  end
end
