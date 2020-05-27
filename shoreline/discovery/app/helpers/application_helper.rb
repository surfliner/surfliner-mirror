# frozen_string_literal: true

module ApplicationHelper
  def current_theme
    @current_theme ||= ENV['SHORELINE_THEME']
  end

  def themed_stylesheet_link_tag(tag)
    return stylesheet_link_tag(tag) if current_theme.nil?

    stylesheet_link_tag "#{tag}_#{current_theme}"
  end

  def render_themed_partial(partial)
    return render partial: partial if current_theme.nil?

    render partial: "#{partial}_#{current_theme}"
  end

  # Tools pane
  def show_doc_actions?
    !ActiveModel::Type::Boolean.new.cast(ENV['SHORELINE_SUPPRESS_TOOLS']) && super
  end
end
