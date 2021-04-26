# frozen_string_literal: true

class CometHomepagePresenter < Hyrax::HomepagePresenter
  ##
  # @note suppress the share work button in Comet
  def display_share_button?
    false
  end
end
