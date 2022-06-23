module ApplicationHelper
  ##
  # given an ojbect, check whether the current user should see a publish
  # button. this is a higher level of abstraction than the +Ability+ driven
  # +#can?(:publish, obj)+ checks; use those if you just want to authorize
  # the current user to publish.
  #
  # @note this interface is intended to be polymorphic, but the current
  # implementation is focused on +Hyrax::PcdmCollection+. if you use this
  # check with other models, you probably need to implement the behavior
  # you want.
  #
  # @param obj [Object] an object to check for publish ability
  #
  # @return [Boolean] true if the publish button should disply
  def show_publish_button?(obj)
    Rails.application.config.feature_collection_publish &&
      can?(:publish, obj)
  end
end
