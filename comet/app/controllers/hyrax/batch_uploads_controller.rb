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

      Hyrax.logger.debug(permitted)

      ##
      # TODO: Handle CSV/Excel? source, build object metadata and ingest files

      redirect_to(new_batch_upload_path,
        notice: t("hyrax.dashboard.batch_uploads.submission_success"))
    end
  end
end
