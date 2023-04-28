# frozen_string_literal: true

module CampusPermissionBadgeOverride
  CAMPUS_VISIBILITY_LABEL_CLASS = {
    authenticated: "label-info",
    campus: "label-primary",
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
    CAMPUS_VISIBILITY_LABEL_CLASS.fetch(@visibility&.to_sym, "label-info")
  end
end

Hyrax::PermissionBadge.class_eval do
  prepend CampusPermissionBadgeOverride
end
