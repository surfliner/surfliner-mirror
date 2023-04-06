# frozen_string_literal: true

class CometPublishedBadge
  include ActionView::Helpers::TagHelper

  PUBLISHED_LABEL_CLASS = {
    published: "label-success",
    unpublished: "label-danger"
  }.freeze

  # @param object [String] the current object id
  def initialize(object)
    @published_platforms = DiscoveryPlatformService.call(object)
  end

  # Draws a span tag with styles for a bootstrap label
  def render
    tag.span(text, class: "label #{dom_label_class}")
  end

  private

  def published?
    @published_platforms.present?
  end

  def dom_label_class
    if published?
      PUBLISHED_LABEL_CLASS.fetch(:published)
    else
      PUBLISHED_LABEL_CLASS.fetch(:unpublished)
    end
  end

  def text
    if published?
      I18n.t("hyrax.publish.published")
    else
      I18n.t("hyrax.publish.unpublished")
    end
  end
end
