module Bulkrax
  ##
  # A custom CsvEntry class for Bulkrax
  class CometCsvEntry < CsvEntry
    def self.parent_field(parser)
      parser.related_parents_parsed_mapping
    end

    def hyrax_record
      @hyrax_record ||= Hyrax.query_service.find_by(id: identifier)
    end

    # Metadata required by Bulkrax for round-tripping
    def build_system_metadata
      parsed_metadata["id"] = hyrax_record.id.to_s
      parsed_metadata[source_identifier] = hyrax_record.alternate_ids.first.to_s
      parsed_metadata[key_for_export("model")] = hyrax_record.class.name
    end

    ##
    # Override to add M3 properties
    def build_export_metadata
      self.parsed_metadata = {}

      build_system_metadata
      build_files_metadata unless hyrax_record.is_a?(Collection)

      # A hack to initiate mapping for related_parents_parsed_mapping to avoid error.
      # see Bulkrax::CsvEntry#build_relationship_metadata
      mapping[related_parents_parsed_mapping] = mapping[related_parents_parsed_mapping] || {}
      build_relationship_metadata

      # Extract M3 properties before other configured mappings.
      # Note: This is not needed unless an empty or incomplete mapping fields are configured.
      # build_m3_metadata

      build_mapping_metadata

      save!

      parsed_metadata
    end

    def build_files_metadata
      # Note: Bulkrax attaching files to the FileSet row only so we don't have duplicates when importing to a new tenant
      # Comet will attach file wth filename as column to objects metadata
      file_mapping = key_for_export("file")
      file_sets = hyrax_record.file_set? ? Array.wrap(hyrax_record) : Hyrax.custom_queries.find_child_file_sets(resource: hyrax_record)
      filenames = map_file_sets(file_sets)
      handle_join_on_export(file_mapping, filenames, mapping["file"]&.[]("join")&.present?)
    end

    ##
    # Override to remove the properties that have custom mappings from parsed_metadata, which are extracted from M3 mappings.
    def build_value(key, value)
      data = hyrax_record.send(key.to_s)
      if data.is_a?(ActiveTriples::Relation)
        if value["join"]
          parsed_metadata[key_for_export(key)] = data.map { |d| prepare_export_data(d) }.join(Bulkrax.multi_value_element_join_on).to_s
        else
          data.each_with_index do |d, i|
            parsed_metadata["#{key_for_export(key)}_#{i + 1}"] = prepare_export_data(d)
          end
        end
      else
        # Now delete the mapping from m3 since custom mapping is defined for the property
        parsed_metadata.delete(key) if parsed_metadata.key? key

        parsed_metadata[key_for_export(key)] = prepare_export_data(data)
      end
    end

    ##
    # Add mappings from M3
    def build_m3_metadata
      Bulkrax::ValkyrieObjectFactory.schema_properties(hyrax_record.class).each do |pro|
        value = hyrax_record.send(pro)
        parsed_metadata[pro] = value.present? ? value.join(Bulkrax.multi_value_element_join_on) : nil
      end

      parsed_metadata["title"] = hyrax_record.send(:title).first
    end

    ##
    # Override to join value array as multi-value string
    def prepare_export_data(datum)
      if datum.is_a?(ActiveTriples::Resource)
        datum.to_uri.to_s
      elsif datum.is_a?(Array)
        datum.present? ? datum.join(Bulkrax.multi_value_element_join_on) : nil
      else
        datum
      end
    end

    private

    def map_file_sets(file_sets)
      file_sets.map { |fs| Hyrax::FileSetFileService.new(file_set: fs)&.original_file&.original_filename }.compact
    end
  end
end
