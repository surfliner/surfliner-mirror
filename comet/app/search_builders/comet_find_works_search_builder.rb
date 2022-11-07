# frozen_string_literal: true

# This search builder drops suppress filter to search for components to add to an object
class CometFindWorksSearchBuilder < ::Hyrax::My::FindWorksSearchBuilder
  self.default_processor_chain -= [:only_active_works]
end
