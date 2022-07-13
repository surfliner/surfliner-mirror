# frozen_string_literal: true

# This search builder drops suppress filter to allow access to collection members for roles like:
# user authorized by workflow
# depositor
class CometCollectionMemberSearchBuilder < ::Hyrax::CollectionMemberSearchBuilder
  self.default_processor_chain -= [:only_active_works]
end
