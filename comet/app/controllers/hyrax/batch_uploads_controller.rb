# frozen_string_literal: true

module Hyrax
  class BatchUploadsController < ApplicationController
    with_themed_layout "dashboard"
    before_action :authenticate_user!

    def new
      @batch_upload = BatchUpload.new
      @form = BatchUploadForm.new(@batch_upload)
    end
  end
end
