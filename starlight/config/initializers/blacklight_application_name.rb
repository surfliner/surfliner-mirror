# frozen_string_literal: true

# Teach the Blacklight helper to pay attention to the Spotlight site names
Blacklight::BlacklightHelperBehavior.module_eval do
  alias_method :blacklight_application_name, :application_name
  def application_name
    current_site.title || blacklight_application_name
  end
end
