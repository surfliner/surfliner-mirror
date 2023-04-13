# frozen_string_literal: true

##
# Provides some visibility methods to +Hyrax::FileMetadata+.
module FileMetadataVisibilityOverride
  def permission_manager
    @permission_manager ||= Hyrax::PermissionManager.new(resource: self)
  end

  def visibility
    visibility_reader.read
  end

  protected

  def visibility_reader
    Hyrax::VisibilityReader.new(resource: self)
  end
end

Hyrax::FileMetadata.class_eval do
  prepend FileMetadataVisibilityOverride
end
