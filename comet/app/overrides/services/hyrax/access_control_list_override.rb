# frozen_string_literal: true

Hyrax::AccessControlList.class_eval do
  ##
  # @Override Don't propagate 'metadata-only visibility over FileSets and Files
  #
  # Copy and save permissions from source to target
  #
  # @param [Valkyrie::Resource, Hyrax::AccessControlList] source
  # @param [Valkyrie::Resource, Hyrax::AccessControlList] target
  #
  # @return [Hyrax::AccessControlList] an acl for `target` with the updated permissions
  def self.copy_permissions_override(source:, target:)
    metadata_only_permission = Comet::PERMISSION_TEXT_VALUE_METADATA_ONLY
    public_permission = Hydra::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_PUBLIC

    target = Hyrax::AccessControlList(target)
    source = Hyrax::AccessControlList(source)
    source_permissions = source.permissions
    metadata_only = source_permissions.any? { |p| p.agent.include?(metadata_only_permission) }

    target.permissions = if metadata_only && (target.resource.is_a?(Hyrax::FileSet) || target.resource.is_a?(Hyrax::FileMetadata))

      # Don't propagate METADATA_ONLY permissions into FileSet and File'
      source_permissions.reject { |p| p.agent.include?(metadata_only_permission) || p.agent.include?(public_permission) }
    else
      source_permissions
    end

    target.save && target
  end

  define_singleton_method(:copy_permissions, singleton_method(:copy_permissions_override))
end
