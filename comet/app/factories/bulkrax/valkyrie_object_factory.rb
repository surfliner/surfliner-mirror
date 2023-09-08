# frozen_string_literal: true

module Bulkrax
  class ValkyrieObjectFactory < ObjectFactory
    ##
    # Retrieve properties from M3 model
    # @param klass the model
    # return Array<string>
    def self.schema_properties(klass)
      schema_definitions(klass).values.map { |pro| pro.name.to_s }
    end

    ##
    # Retrieve schema definitions for M3 model
    # @param klass the model
    # return Hash
    def self.schema_definitions(klass)
      @schema_definitions_map ||= {}

      klass_key = klass.name
      unless @schema_definitions_map.has_key?(klass_key)
        @schema_definitions_map[klass_key] = ::SchemaLoader.new.properties_for(klass.name.underscore.to_sym)
      end

      @schema_definitions_map[klass_key]
    end

    def run!
      run
      return object if object.persisted?

      raise(RecordInvalid, object)
    end

    def find_by_id
      Hyrax.query_service.find_by(id: attributes[:id]) if attributes.key? :id
    end

    def search_by_identifier
      # Query can return partial matches (something6 matches both something6 and something68)
      # so we need to weed out any that are not the correct full match. But other items might be
      # in the multivalued field, so we have to go through them one at a time.
      match = Hyrax.query_service.find_by_alternate_identifier(alternate_identifier: source_identifier_value)

      return match if match
    rescue => err
      Hyrax.logger.error(err)
      false
    end

    # An ActiveFedora bug when there are many habtm <-> has_many associations means they won't all get saved.
    # https://github.com/projecthydra/active_fedora/issues/874
    # 2+ years later, still open!
    def create
      attrs = transform_attributes
        .merge(alternate_ids: [source_identifier_value])
        .symbolize_keys

      cx = Hyrax::Forms::ResourceForm.for(klass.new).prepopulate!
      cx.validate(attrs)

      result = transaction
        .with_step_args(
          # "work_resource.add_to_parent" => {parent_id: @related_parents_parsed_mapping, user: @user},
          "work_resource.add_bulkrax_files" => {files: get_s3_files, user: @user},
          "change_set.set_user_as_depositor" => {user: @user},
          "work_resource.change_depositor" => {user: @user}
          # TODO: uncomment when we upgrade Hyrax 4.x
          # 'work_resource.save_acl' => { permissions_params: [attrs.try('visibility') || 'open'].compact }
        )
        .call(cx)

      @object = result.value!

      @object
    end

    def update
      raise "Object doesn't exist" unless @object

      destroy_existing_files if @replace_files && ![Collection, FileSet].include?(klass)

      attrs = transform_attributes(update: true)

      cx = Hyrax::Forms::ResourceForm.for(@object)
      cx.validate(attrs)

      result = update_transaction
        .with_step_args(
          "work_resource.add_bulkrax_files" => {files: get_s3_files, user: @user}

          # TODO: uncomment when we upgrade Hyrax 4.x
          # 'work_resource.save_acl' => { permissions_params: [attrs.try('visibility') || 'open'].compact }
        )
        .call(cx)

      @object = result.value!
    end

    # @return [Hash<Symbol>, Array<Fog::AWS::Storage::File>>]
    #   example { service_file: [s3file1, s3file2], preservation_file: [s3preservationfile] }
    def get_s3_files
      return {} unless permitted_file_attributes.any? { |k| file_attributes.key?(k) }

      s3_bucket_name = ENV.fetch("STAGING_AREA_S3_BUCKET", "comet-staging-area-#{Rails.env}")
      s3_bucket = Rails.application.config.staging_area_s3_connection
        .directories.get(s3_bucket_name)

      results = {}

      permitted_file_attributes.each do |attr|
        urls = []
        attr_files = file_attributes[attr]
        Hyrax.logger.info "Will try to assign #{attr_files} with from attribute #{attr}"
        if attr_files.blank?
          Hyrax.logger.info "No #{attr} files listed for #{attributes["source_identifier"]}"
          next
        end
        attr_files.map { |r| r[:url] }.map do |key|
          Hyrax.logger.info "Loading file #{key} from s3 bucket #{s3_bucket_name}"
          url = s3_bucket.files.get(key)
          unless url
            Hyrax.logger.warn("Failed to load file #{key} from s3 bucket #{s3_bucket_name}")
            next
          end
          urls << url
        end
        results[use_for_file(attr)] = urls unless urls.empty?
      end.compact

      results
    end

    ##
    # TODO: What else fields are necessary: %i[id edit_users edit_groups read_groups work_members_attributes]?
    # Regardless of what the Parser gives us, these are the properties we are prepared to accept.
    def permitted_attributes
      Bulkrax::ValkyrieObjectFactory.schema_properties(klass) +
        %i[
          admin_set_id
          title
          visibility
        ]
    end

    def apply_depositor_metadata(object, user)
      object.depositor = user.email
      object = Hyrax.persister.save(resource: object)
      Hyrax.publisher.publish("object.metadata.updated", object: object, user: @user)
      object
    end

    # @Override - support multiple fields for remote file ingest
    def file_attributes(update_files = false)
      @update_files = update_files
      hash = {}
      return hash if klass == Collection
      hash[:uploaded_files] = upload_ids if attributes[:file].present?
      permitted_file_attributes.each do |a|
        hash[a] = new_remote_files(a) if attributes[a].present?
      end
      hash
    end

    # @Override - Addition of file_attribute parameter
    # @file_attribute [String] Valid attribute for remote file upload
    # Its possible to get just an array of strings here, so we need to make sure they are all hashes
    def parsed_remote_files(file_attribute)
      Hyrax.logger.info "parsed_remote_files for #{file_attribute} with values #{attributes[file_attribute]} which is a #{attributes[file_attribute].class}"
      remote_files = attributes[file_attribute] || []
      remote_files = remote_files.map do |file_value|
        if file_value.is_a?(Hash)
          file_value
        elsif file_value.is_a?(String)
          name = Bulkrax::Importer.safe_uri_filename(file_value)
          {url: file_value, file_name: name}
        else
          Rails.logger.error("skipped remote file #{file_value} because we do not recognize the type")
          nil
        end
      end
      remote_files.delete(nil)
      remote_files
    end

    # @Override remove branch for FileSets replace validation with errors
    # @file_attribute [String] Valid attribute for remote file upload
    def new_remote_files(file_attribute)
      if @object.is_a? FileSet
        parsed_remote_files(file_attribute).select do |file|
          # is the url valid?
          is_valid = file[:url]&.match(URI::ABS_URI)
          # does the file already exist
          is_existing = @object.import_url && @object.import_url == file[:url]
          is_valid && !is_existing
        end
      else
        parsed_remote_files(file_attribute)
        # TODO: at this point they aren't absolute uri's they're relative.. how did this work for remote_files?
        # parsed_remote_files(file_attribute).select do |file|
        #   file[:url]&.match(URI::ABS_URI) #
        # end
      end
    end

    # @Override Destroy existing files with Hyrax::Transactions
    def destroy_existing_files
      existing_files = fetch_child_file_sets(resource: @object)

      existing_files.each do |fs|
        Hyrax::Transactions::Container["file_set.destroy"]
          .with_step_args("file_set.remove_from_work" => {user: @user},
            "file_set.delete" => {user: @user})
          .call(fs)
          .value!
      end

      @object.member_ids = @object.member_ids.reject { |m| existing_files.detect { |f| f.id == m } }
      @object.rendering_ids = []
      @object.representative_id = nil
      @object.thumbnail_id = nil
    end

    private

    # @return [Array<String> attributes which are permitted for referencing files to ingest
    def permitted_file_attributes
      ["remote_files"] + attributes.keys.keep_if { |a| a.start_with?("use:") }
    end

    # @param String header value which typicall will contain the use:<PCDMUse> as a value
    # example: use:PreservationFile
    # @return Symbol use symbol for generating RDF::URI
    def use_for_file(header)
      return :original_file if header.eql? "remote_files"
      return :original_file unless header.start_with?("use:")

      header.gsub("use:", "").underscore.to_sym
    end

    def transaction
      Hyrax::Transactions::Container["work_resource.create_with_bulk_behavior"]
    end

    # Customize Hyrax::Transactions::WorkUpdate transaction with bulkrax
    def update_transaction
      Hyrax::Transactions::Container["work_resource.update_with_bulk_behavior"]
    end

    # Query child FileSet in the resource/object
    def fetch_child_file_sets(resource:)
      Hyrax.custom_queries.find_child_file_sets(resource: resource)
    end
  end

  class RecordInvalid < StandardError
  end
end
