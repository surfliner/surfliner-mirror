# frozen_string_literal: true

# This search builder overrides suppress filter to allow access to collections by roles:
# user authorized by workflow
# depositor
class CometCollectionMemberSearchBuilder < ::Hyrax::CollectionMemberSearchBuilder
  include Hyrax::FilterSuppressedWithRoles
end
