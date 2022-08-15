class Collection < Valkyrie::Resource
  attribute :title, Valkyrie::Types::Array.of(Valkyrie::Types::String)

  def self.all_discoverable_parents(resource:, agent:)
    Superskunk.comet_query_service.find_many_by_ids(
      ids: [
        # TODO: Replace this (empty) array with a single query which returns
        # all the AccessControl resources which have an +access_to+ which is one
        # of the +resource.member_of_collection_ids+.
      ].filter { |access_control|
        # We can’t use +AccessControlList+ here because there is no mechanism to
        # create one from just an +AccessControl+. But we can just check the
        # permissions manually.
        next unless access_control.is_a?(Hyrax::Acl::AccessControl)
        access_control.permissions.any? do |permission|
          permission.mode == :discover && permission.agent == agent.agent_key
        end
      }.map(&:access_to)
    )
  end
end
