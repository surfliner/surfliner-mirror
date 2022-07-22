##
# A discovery platform, which may or may not have been granted access to a given
# resource by Comet.
class DiscoveryPlatform < Hyrax::Acl::Group
  def initialize(agent_name)
    super(agent_name)
  end

  ##
  # Returns whether this discovery platform has been granted access the provided
  # resource.
  #
  # In ACL terms,  this implies a `:discover` grant.
  def has_access?(resource:)
    begin
      access_control = Hyrax::Acl::CustomQueries::FindAccessControl.new(query_service: Superskunk.comet_query_service)
        .find_access_control_for(resource: resource)
    rescue Valkyrie::Persistence::ObjectNotFoundError
      access_control = Hyrax::Acl::AccessControl.new(access_to: resource.id, permissions: [])
    end

    acl = Hyrax::Acl::AccessControlList.new(access_control: access_control)
    acl.has_discover?(agent: self)
  end

  ##
  # Raised when a discovery platform cannot be identified or authenticated.
  class AuthError < StandardError
  end

  ##
  # Returns a new DiscoveryPlatform generated from the provided request.
  def self.from_request(request)
    # The name is the User-Agent up to the first slash, whitespace, or o·paren.
    #
    # This may change (or throw an AuthError) once we have proper auth in place.
    user_agent = request.headers["User-Agent"].to_s
    raise AuthError.new("Empty User-Agent string") unless user_agent.present?
    new(user_agent.match(/[^\/ \t(]*/)[0])
  end
end
