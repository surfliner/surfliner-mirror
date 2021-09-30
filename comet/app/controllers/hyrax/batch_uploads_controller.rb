# frozen_string_literal: true

module Hyrax
  class BatchUploadsController < ApplicationController
    include BatchUploadsControllerBehavior

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

      persist_batch_upload_record(permitted: permitted)

      source_path = permitted[:source_file].path

      source_validator = ::BatchUploadsValidator.validator_for("batch_uploads_validation")

      rows = ::TabularParser
        .for(content_type: permitted[:source_file].content_type)
        .parse(source_path)

      # Validate headers
      invalid_headers = source_validator.invalid_headers(rows.first)
      if invalid_headers.any?
        redirect_to(new_batch_upload_path,
          alert: "Validation failed! Invalid headers: #{invalid_headers.join(", ")}.")
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
    end
  end
end
