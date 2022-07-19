##
# A discovery platform, which may or may not have been granted access to a given
# resource by Comet.
class DiscoveryPlatform
  def initialize(agent_name)
    @agent_name = agent_name
  end

  attr_reader :agent_name

  ##
  # The agent key used to identify this discovery platform in access control
  # lists.
  def agent_key
    self.class.agent_prefix + agent_name
  end

  ##
  # Returns whether this discovery platform has been granted access the provided
  # resource.
  #
  # In ACL terms,  this implies a `:discover` grant.
  def has_access?(resource:)
    return true if Rails.application.config.always_allow_access_to_platforms.to_a.include?(agent_name)
    false # to come
  end

  ##
  # Raised when a discovery platform cannot be identified or authenticated.
  class AuthError < StandardError
  end

  ##
  # A prefix applied to the agent name in order to construct the agent key for
  # this discovery platform.
  #
  # For compatibility with Hyrax, the prefix is "group/".
  def self.agent_prefix
    "group/"
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
