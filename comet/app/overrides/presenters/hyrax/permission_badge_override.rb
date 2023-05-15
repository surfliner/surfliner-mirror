# frozen_string_literal: true

module PermissionBadgeOverride
  COMET_VISIBILITY_LABEL_CLASS = {
    authenticated: "badge-info",
    comet: "badge-primary",
    campus: "badge-info",
    metadata_only: "badge-warning",
    embargo: "badge-warning",
    lease: "badge-warning",
    open: "badge-success",
    restricted: "badge-danger"
  }.freeze

  # Draws a span tag with styles for a bootstrap label
  def render
    tag.span(text, class: "badge #{dom_label_class}")
  end

  private

  def dom_label_class
    COMET_VISIBILITY_LABEL_CLASS.fetch(@visibility&.to_sym, "badge-info")
  end
end

Hyrax::PermissionBadge.class_eval do
  prepend PermissionBadgeOverride
end
