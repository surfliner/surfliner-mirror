# frozen_string_literal: true

if Rails.application.config.feature_bulkrax
  Bulkrax.setup do |config|
    config.object_factory = Bulkrax::ValkyrieObjectFactory
    config.default_work_type = 'GenericObject'
  end

  Hyrax::DashboardController.sidebar_partials[:repository_content] <<
    "hyrax/dashboard/sidebar/bulkrax_sidebar_additions"
end
