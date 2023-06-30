# frozen_string_literal: true

# Methods for uploading files and attaching them to Valkyrie resources
module FileIngest
  # @param [String] filename
  # @param [String] last_modified
  # @param [Array<String>] permissions
  # @param [User] user
  # @param [Valkyrie::Resource] work
  def self.make_fileset_for(
    filename:,
    user:, work:, last_modified: Hyrax::TimeService.time_in_utc,
    permissions: []
  )
    fs = Hyrax::FileSet.new(
      depositor: user.id,
      creator: user.id,
      date_uploaded: Hyrax::TimeService.time_in_utc,
      date_modified: last_modified,
      label: filename,
      title: filename
    )

    file_set = Hyrax.persister.save(resource: fs)
    Hyrax::AccessControlList.copy_permissions(source: permissions, target: file_set)

    work.member_ids << file_set.id
    work.representative_id = file_set.id if work.respond_to?(:representative_id) && work.representative_id.blank?
    work.thumbnail_id = file_set.id if work.respond_to?(:thumbnail_id) && work.thumbnail_id.blank?
    work.rendering_ids << file_set.id

    Hyrax.persister.save(resource: work)
    Hyrax.publisher.publish("object.metadata.updated", object: work, user: user)

    file_set
  end

  # @param [String] content_type
  # @param [File] file_body
  # @param [String] filename
  # @param [String] last_modified
  # @param [Int] size]
  # @param [User] user
  # @param [Valkyrie::Resource] work
  # @param [Symbol] use
  def self.upload(
    content_type:,
    file_body:,
    filename:,
    last_modified:,
    permissions:,
    size:,
    user:,
    work:,
    use: :original_file
  )

    file_set = FileIngest.make_fileset_for(
      filename: filename,
      last_modified: last_modified,
      permissions: permissions,
      user: user,
      work: work
    )

    file_metadata =
      Hyrax::FileMetadata.new(
        file_set_id: file_set.id,
        label: filename,
        mime_type: content_type,
        original_filename: filename,
        type: Hyrax::FileMetadata::Use.uri_for(use: use),
        size: size
      )
    saved_metadata = Hyrax.persister.save(resource: file_metadata)

    Hyrax::AccessControlList.copy_permissions(
      source: permissions,
      target: saved_metadata
    )

    uploaded = Hyrax.storage_adapter.upload(
      resource: saved_metadata,
      file: file_body,
      original_filename: filename
    )

    saved_metadata.file_identifier = uploaded.id
    doubly_saved_metadata = Hyrax.persister.save(resource: saved_metadata)

    Hyrax.publisher.publish("file.metadata.updated", metadata: doubly_saved_metadata, user: user)
    Hyrax.publisher.publish("object.file.uploaded", metadata: doubly_saved_metadata, file: uploaded)

    file_set.file_ids << uploaded.id

    saved_fs = Hyrax.persister.save(resource: file_set)

    Hyrax.publisher.publish("object.metadata.updated", object: saved_fs, user: user)
    Hyrax.publisher.publish("file.set.attached", file_set: saved_fs, user: user)
  end
end
