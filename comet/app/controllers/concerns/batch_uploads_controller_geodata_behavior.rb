# frozen_string_literal: true

##
# A base module to resolve requests for CSV geodata batch uploads.
module BatchUploadsControllerGeodataBehavior
  FILE_NAMES_KEY = "file_names"
  ORIGINAL_FILE_KEY = "originalfile"

  ##
  # Build and ingest metadata and file()s of an object
  def ingest_geodata_object(attrs, file_path)
    process_attrs attrs

    attrs[:depositor] = current_user.email

    perform_geodata_ingest(attrs, current_user, GenericObject, file_path)
  end

  # Ingest object metadata and files
  # @param attrs[Hash]
  # @param user[User] - the depositor
  # @param model[String] - the model name of the object to create
  # @param file_path[String] - the base path to files
  def perform_geodata_ingest(attrs, user, model, file_path)
    # files for the geospatial object
    file_names = attrs.delete(FILE_NAMES_KEY)

    # create objcect with workflow
    # TODO: use m3 for to map fields
    work = ingest_metadata(attrs, user, model)

    # ingest the files
    ingest_geodata_files(work, file_path, file_names, user) if file_names.present?

    # Index the object
    Hyrax.publisher.publish("object.metadata.updated", object: work, user: user)

    work
  end

  # Ingest the files into a single fileset
  # @param work[GenericObject]
  # @param file_path[String] - the base path to files
  # @param file_names[Array<String>] - the base path to files
  # @param user[User] - the depositor
  def ingest_geodata_files(work, file_path, file_names, user)
    file_service = InlineBatchUploadGeodataHandler.new(work: work)
    file_service.add(files: build_geodata_files(user, file_path, file_names))
    file_service.attach

    Hyrax.persister.save(resource: work)
  end

  ##
  # Build upload file(s)
  # @param user [User] - the depositor
  # @param file_names Array [String] - the filenames
  # @param file_path Array [String] - the parent directory
  # @return Array [BatchUploadFile]
  def build_geodata_files(user, file_path, file_names)
    [].tap do |p|
      file_names.each do |fn|
        staging_area_file = create_staging_area_file(file_path, fn, get_file_use(file_name: fn))
        p << BatchUploadFile.new(user: user, file: staging_area_file)
      end
    end
  end

  ##
  # Group files by the primary .shp file filename (strip off extension) as the key
  # @param files_path [string] - the path in staging area
  def get_object_files(files_path)
    file_names = list_files(files_path).sort
    {}.tap do |pro|
      primary_files = file_names.select { |fn| fn.end_with?(InlineBatchUploadGeodataHandler::PRIMARY_FILE_EXTENSION) }
      primary_files.each do |file|
        key = key_for(file_name: file)
        pro[key] = Array.wrap(file) if pro[key].blank?
      end

      file_names.each do |fn|
        key = key_for(file_name: fn)
        pro[key] << fn unless !pro.key?(key) || pro[key].include?(fn)
      end
    end
  end

  ##
  # file use for geospatial files
  def get_file_use(file_name:)
    case File.extname(file_name)
    when InlineBatchUploadGeodataHandler::PRIMARY_FILE_EXTENSION
      :geoshape_file
    else
      Hyrax.logger.warn("Unhandle geospacial file extension with file #{file_name}.")
      :original_file
    end
  end

  ##
  # Key of a file (with file extension stripped off)
  # @param file_name [string]
  def key_for(file_name:)
    file_name[0..file_name.index(".") - 1] unless file_name.blank?
  end
end
