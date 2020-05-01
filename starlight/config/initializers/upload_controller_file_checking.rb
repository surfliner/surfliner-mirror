# frozen_string_literal: true

require "csv"
require "spotlight"

Rails.application.config.after_initialize do
  Spotlight::Resources::CsvUploadController.class_eval do
    def create
      flash[:alert] = []

      csv = CSV.parse(csv_io_param, headers: true, return_headers: false).map(&:to_hash)
      csv.each do |row|
        next if row["file"].blank?

        full_path = Pathname.new(ENV["BINARY_ROOT"] || "").join(row["file"])
        unless full_path.exist?
          flash[:alert] << "No file exists at #{full_path}; skipping"
        end
      end

      Spotlight::AddUploadsFromCSV.perform_later(csv, current_exhibit, current_user)
      flash[:notice] = t("spotlight.resources.upload.csv.success", file_name: csv_io_name)
      redirect_back(fallback_location: spotlight.exhibit_resources_path(current_exhibit))
    end
  end
end
