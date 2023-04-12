# frozen_string_literal: true

module ResourceVisibilityPropagatorOverride
  ##
  # Override the default +Hyrax::ResourceVisibilityPropagator.propagate+ to also
  # propagate ACLs to the files within file sets.
  def propagate
    queries.find_child_file_sets(resource: source).each do |file_set|
      # Copy ACLs from source to child file sets and save.
      Hyrax::AccessControlList.copy_permissions(source: source, target: file_set)

      # Copy leases and embargos to child file sets and save.
      embargo_manager.copy_embargo_to(target: file_set)
      lease_manager.copy_lease_to(target: file_set)
      persister.save(resource: file_set)

      # Update the ACLs for the files within the file sets as well.
      queries.find_files(file_set: file_set).each do |file|
        Hyrax::AccessControlList.copy_permissions(source: source, target: file)
      end
    end
  end
end

Hyrax::ResourceVisibilityPropagator.class_eval do
  prepend ResourceVisibilityPropagatorOverride
end
