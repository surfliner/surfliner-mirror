require "action_view"

module ActionView::Helpers::TranslationHelper
  ##
  # Returns a scoped and themed translation key, using "default" if no current
  # theme is set.
  #
  # The theme is prefixed to the last element of the scoped key, wrapped in
  # parentheses.
  #
  # This code relies on the private +scope_key_by_partial+ method, which is used
  # to resolve keys which begin with a dot.
  def scoped_themed_translation_key_by_partial(key)
    string_key = scope_key_by_partial(key).to_s
    key_scopes = string_key.split(".", -1)
    scoped_key = "(#{current_theme || "default"})#{key_scopes.pop}".to_sym
    "#{key_scopes.join(".")}.#{scoped_key}"
  end
end
