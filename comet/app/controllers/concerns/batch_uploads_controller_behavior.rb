# frozen_string_literal: true

##
# A base module to resolve requests for batch uploads.
module BatchUploadsControllerBehavior
  private

  ##
  # @api private
  #
  # Wrap up files from local mounted staging area for upload
  class StagingAreaFile
    attr_reader :path, :filename, :original_filename

    def initialize(path:, filename:)
      @path = path
      @filename = filename
      @original_filename = filename
    end

    # Content type of a file
    def content_type
      Rack::Mime.mime_type(File.extname(filename)) || "binary/octet-stream"
    end

    ##
    # Create file object for S3/Shrine upload
    def io_file
      File.open(File.join(@path, @filename))
    end
  end

  ##
  # @api private
  #
  # Wrap up files from S3/Minio staging area for upload
  class S3StagingAreaFile < StagingAreaFile
    attr_reader :s3_handler

    ##
    # @param path [String] - the prefix to the file like my-project/
    # @param filename [String] - the filename
    # @param s3_handler [StagingAreaS3Handler]
    def initialize(path:, filename:, s3_handler:)
      super(path: path, filename: filename)

      @s3_handler = s3_handler
    end

    ##
    # Create IO-like Down::ChunkedIO object for S3/Shrine upload
    def io_file
      s3_handler = Rails.application.config.staging_area_s3_handler
      Down.download s3_handler.file_url("#{path}#{filename}")
    end
  end

  ##
  # Build and ingest metadata and file()s of an object
  def ingest_object(attrs, file_path)
    process_attrs attrs

    attrs[:depositor] = current_user.email

    perform_ingest(attrs, current_user, ::GenericObject, file_path)
  end

  ##
  # Process multi-value fields, clean up and convert values if needed
  def process_attrs(attrs)
    attrs.dup.map do |k, v|
      attrs[k] = v.split("|").map { |val| val.strip }
    end
  end

  # Ingest object metadata and files
  # @param attrs[Hash]
  # @param user[User] - the depositor
  # @param model[String] - the model name of the object to create
  # @param file_path[String] - the base path to files
  def perform_ingest(attrs, user, model, file_path)
    file_names = attrs.delete("file name")

    # Create object
    work = model.new
    attrs.each { |k, v| work.public_send("#{k}=", v) if work.respond_to?(k.to_s) }
    work = Hyrax.persister.save(resource: work)

    # Upload file(s)
    if file_names.present?
      file_service = InlineBatchUploadHandler.new(work: work)
      file_service.add(files: build_files(user, file_path, file_names))
      file_service.attach

      work = Hyrax.persister.save(resource: work)
    end

    # Add to workflow
    Hyrax::Workflow::WorkflowFactory.create(work, {}, user)

    # Index the object
    Hyrax.index_adapter.save(resource: work)

    work
  end

  ##
  # Build upload file(s)
  # @param user [User] - the depositor
  # @param file_names Array [String] - the filenames
  # @param file_path Array [String] - the parent directory
  # @return Array [BatchUploadFile]
  def build_files(user, file_path, file_names)
    [].tap do |p|
      file_names.each do |f|
        staging_area_file = create_staging_area_file(file_path, f)
        p << BatchUploadFile.new(user: user, file: staging_area_file)
      end
    end
  end

  ##
  # Create staging area file
  # @param path [String] - the parent directory
  # @param filename [String] - the filename
  # @return [StagingAreaFile]
  def create_staging_area_file(path, filename)
    s3_enabled = Rails.application.config.staging_area_s3_enabled
    return StagingAreaFile.new(path: path, filename: filename) unless s3_enabled

    s3_handler = Rails.application.config.staging_area_s3_handler
    S3StagingAreaFile.new(path: path, filename: filename, s3_handler: s3_handler)
  end
end
