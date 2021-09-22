# frozen_string_literal: true

##
# A base module to resolve requests for batch uploads.
module BatchUploadsControllerBehavior
  private

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
      file_service = InlineUploadHandler.new(work: work)
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
  # @param user
  # @param file_names
  # @param file_path
  def build_files(user, file_path, file_names)
    [].tap do |p|
      file_names.each do |f|
        io_file = File.open "#{file_path}/#{f}"
        p << Hyrax::UploadedFile.create(user: user, file: io_file)
      end
    end
  end
end
