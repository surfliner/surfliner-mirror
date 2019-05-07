# frozen_string_literal: true

# Teach the Blacklight helper to pay attention to the Spotlight site names
Blacklight::BlacklightHelperBehavior.module_eval do
  def application_name
    current_site.title || super
  end
end
