# frozen_string_literal: true

module Bulkrax
  ##
  # A custom CsvParser for Bulkrax
  class CometCsvParser < CsvParser
    ##
    # Note: use 'perform_now' to facilitate development for now
    # @return [String]
    def perform_method
      "perform_now"
    end

    # Set the following instance variables: @work_ids, @collection_ids, @file_set_ids
    # @see #current_record_ids
    def set_ids_for_exporting_from_importer
      entry_ids = Bulkrax::Importer.find(importerexporter.export_source).entries.pluck(:id)
      complete_statuses = Bulkrax::Status.latest_by_statusable
        .includes(:statusable)
        .where("bulkrax_statuses.statusable_id IN (?) AND bulkrax_statuses.statusable_type = ? AND status_message = ?", entry_ids, "Bulkrax::Entry", "Complete")
      complete_entry_identifiers = complete_statuses.map { |s| s.statusable&.identifier&.gsub(":", ":") }

      all_results = Hyrax.custom_queries.find_many_by_alternate_ids(alternate_ids: complete_entry_identifiers)
      {:@work_ids => ::Hyrax.config.curation_concerns, :@collection_ids => [::Collection], :@file_set_ids => [::FileSet]}.each do |instance_var, models_to_search|
        instance_variable_set(instance_var, all_results.select { |w| models_to_search.any? { |m| w.is_a? m } }.map { |w| w.id.to_s })
      end
    end

    ##
    # Override to reomve the have exclamation mark from`Array.uniq` to avoid error "undefined method `delete" for nil:NilClass"
    def object_names
      return @object_names if @object_names

      @object_names = mapping.values.map { |value| value["object"] }
      @object_names.uniq.delete(nil)

      @object_names
    end

    # find the related file set ids so entries can be made for export
    def find_child_file_sets(work_ids)
      work_ids.each do |id|
        work = Hyrax.query_service.find_by(id: id)
        Hyrax.custom_queries.find_child_file_set_ids(resource: work).each { |fs_id| @file_set_ids << fs_id.to_s }
      end
    end

    def store_files(identifier, folder_count)
      record = Hyrax.query_service.find_by(id: identifier)
      return unless record

      file_sets = record.file_set? ? Array.wrap(record) : Hyrax.custom_queries.find_child_file_sets(resource: record)
      file_sets << record.thumbnail if exporter.include_thumbnails && record.thumbnail.present? && record.work?
      file_sets.each do |fs|
        path = File.join(exporter_export_path, folder_count, "files")
        FileUtils.mkdir_p(path) unless File.exist? path
        # file = filename(fs)
        # next if file.blank? || fs.original_file.blank?
        file_metadata = Hyrax::FileSetFileService.new(file_set: fs).original_file
        file = Hyrax.storage_adapter.find_by(id: file_metadata.file_identifier)

        file.rewind
        File.open(File.join(path, file_metadata.original_filename), "wb") do |f|
          f.write(file.read)
          f.close
        end
      end
    end
  end
end
