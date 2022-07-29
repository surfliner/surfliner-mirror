# frozen_string_literal: true

module Hyrax
  class BatchUploadsController < ApplicationController
    include BatchUploadsControllerBehavior

    with_themed_layout "dashboard"
    before_action :authenticate_user!

    def new
      @batch_upload_option = params[:option]
      @batch_upload_options = BatchUpload.ingest_options
      @batch_upload = BatchUpload.new
      @form = BatchUploadForm.new(@batch_upload)
    end

    def create
      s3_enabled = Rails.application.config.staging_area_s3_enabled
      files_only_ingest = params[:option] == BatchUpload.files_only_ingest
      permitted = s3_enabled && files_only_ingest ? params.permit(:files_location)
        : params.require(:batch_upload).permit(:source_file, :files_location)

      permitted = permitted.merge(files_location: params.require(:files_location)) if s3_enabled

      Hyrax.logger.debug(permitted)

      source_path = files_only_ingest ? create_csv_sources_with_files(permitted[:files_location])
        : permitted[:source_file].path
      content_type = files_only_ingest ? "text/csv" : permitted[:source_file].content_type

      persist_batch_upload_record(permitted: permitted, source_file: source_path)

      source_validator = ::BatchUploadsValidator.validator_for("batch_uploads_validation")

      rows = ::TabularParser
        .for(content_type: content_type)
        .parse(source_path)

      # Validate headers
      invalid_headers = source_validator.invalid_headers(rows.first)
      if invalid_headers.any?
        redirect_to(new_batch_upload_path,
          alert: "Validation failed! Invalid headers: #{invalid_headers.join(", ")}.")
        return
      end

      # check for files not presented in the file location
      files = rows.map { |r| r[FILE_NAME_KEY] }.to_a
      files_missing = files - list_files(permitted[:files_location])
      if files_missing.size > 0
        redirect_to(new_batch_upload_path,
          alert: "Error missing staging area #{"file".pluralize(files_missing.size)}: #{files_missing.join(", ")}.")
        return
      end

      rows.each_with_index do |row, i|
        # TODO: override license, visibility, embargo_release_date etc. From form?

        # TODO: AdministrativeSet submitted from form?
        admin_sets = Hyrax.query_service.find_all_of_model(model: Hyrax::AdministrativeSet)
        admin_set = admin_sets.find { |p| !Hyrax::PermissionTemplate.find_by(source_id: p.id.to_s).nil? }
        row["admin_set_id"] = admin_set.id.to_s if admin_set

        ingest_object(row.with_indifferent_access, permitted[:files_location])
        # TODO: build object/component relationship, link to collections etc.
      end

      redirect_to(my_works_path,
        notice: t("hyrax.dashboard.batch_uploads.submission_success"))
    rescue => err
      Hyrax.logger.error(err)

      redirect_to(new_batch_upload_path,
        alert: "Error: #{err}.")
    end
  end
end
