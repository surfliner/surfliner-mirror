# frozen_string_literal: true

module AccessControlListOverride
  METADATA_ONLY = Comet::PERMISSION_TEXT_VALUE_METADATA_ONLY
  PUBLIC = Hydra::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_PUBLIC

  ##
  # @Override Don't propagate 'metadata-only visibility over FileSets and Files
  #
  # Copy and save permissions from source to target
  #
  # @param [Valkyrie::Resource, Hyrax::AccessControlList] source
  # @param [Valkyrie::Resource, Hyrax::AccessControlList] target
  #
  # @return [Hyrax::AccessControlList] an acl for `target` with the updated permissions
  def self.copy_permissions(source:, target:)
    target = Hyrax::AccessControlList(target)
    source = Hyrax::AccessControlList(source)
    source_permissions = source.permissions
    metadata_only = source_permissions.any? { |p| p.agent.include?(METADATA_ONLY) }

    target.permissions = if metadata_only && (target.resource.is_a?(Hyrax::FileSet) || target.resource.is_a?(Hyrax::FileMetadata))

      # Don't propagate METADATA_ONLY permissions into FileSet and File'
      source_permissions.reject { |p| p.agent.include?(METADATA_ONLY) || p.agent.include?(PUBLIC) }
    else
      source_permissions
    end

    target.save && target
  end
end

[Hyrax::AccessControlList, Hyrax::AccessControlList.singleton_class].class_eval do |mod|
  mod.prepend AccessControlListOverride
end
