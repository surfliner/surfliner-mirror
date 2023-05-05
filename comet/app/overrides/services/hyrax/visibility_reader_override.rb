# frozen_string_literal: true

module VisibilityReaderOverride
  ##
  # @return [String]
  def read
    if permission_manager.read_groups.include? Comet::PERMISSION_TEXT_VALUE_METADATA_ONLY
      visibility_map.visibility_for(group: Comet::PERMISSION_TEXT_VALUE_METADATA_ONLY)
    elsif permission_manager.read_groups.include? Hydra::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_PUBLIC
      visibility_map.visibility_for(group: Hydra::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_PUBLIC)
    elsif permission_manager.read_groups.include? Hydra::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_AUTHENTICATED
      visibility_map.visibility_for(group: Hydra::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_AUTHENTICATED)
    elsif permission_manager.read_groups.include? Comet::PERMISSION_TEXT_VALUE_CAMPUS
      visibility_map.visibility_for(group: Comet::PERMISSION_TEXT_VALUE_CAMPUS)
    elsif permission_manager.read_groups.include? Comet::PERMISSION_TEXT_VALUE_COMET
      visibility_map.visibility_for(group: Comet::PERMISSION_TEXT_VALUE_COMET)
    else
      visibility_map.visibility_for(group: :PRIVATE)
    end
  end
end

Hyrax::VisibilityReader.class_eval do
  prepend VisibilityReaderOverride
end
