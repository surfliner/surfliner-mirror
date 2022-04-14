require "action_view"

module ActionView::Helpers::TranslationHelper
  alias_method :plain_translate, :translate

  def translate(key, **options)
    key = key&.to_s unless key.is_a?(Symbol)
    begin
      # Attempt to translate the given key with the current theme.
      string_key = scope_key_by_partial(key).to_s
      key_scopes = string_key.split(".", -1)
      scoped_key = "(#{current_theme || "default"})#{key_scopes.pop}".to_sym
      scoped_options = options.clone
      scoped_options[:scope] = (scoped_options[:scope] || []) + key_scopes.map(&:to_sym)
      scoped_options[:raise] = true
      return plain_translate(scoped_key, **scoped_options)
    rescue
    end
    plain_translate(key, **options)
  end
  alias_method :t, :translate
end
