# frozen_string_literal: true

module PermissionBadgeOverride
  COMET_VISIBILITY_LABEL_CLASS = {
    authenticated: "label-info",
    comet: "label-primary",
    campus: "label-primary",
    metadata_only: "label-warning",
    embargo: "label-warning",
    lease: "label-warning",
    open: "label-success",
    restricted: "label-danger"
  }.freeze

  # Draws a span tag with styles for a bootstrap label
  def render
    tag.span(text, class: "label #{dom_label_class}")
  end

  private

  def dom_label_class
    COMET_VISIBILITY_LABEL_CLASS.fetch(@visibility&.to_sym, "label-info")
  end
end

Hyrax::PermissionBadge.class_eval do
  prepend PermissionBadgeOverride
end
