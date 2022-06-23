module ApplicationHelper
  ##
  # @param [Object] an object to check for publish ability
  #
  # @return [Boolean]
  def show_publish_button?(obj)
    Rails.application.config.feature_collection_publish &&
      can?(:publish, obj)
  end
end
