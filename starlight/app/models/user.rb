class User < ApplicationRecord
  include Spotlight::User
  if Blacklight::Utils.needs_attr_accessible?
    attr_accessible :email
  end

  # Connects this user object to Blacklights Bookmarks.
  include Blacklight::User

  devise :omniauthable, omniauth_providers: [:shibboleth]

  # Override this Spotlight method since we're using LDAP for auth and don't
  # need to invite people to create accounts
  def invite_pending?
    false
  end

  # Method added by Blacklight; Blacklight uses #to_s on your
  # user class to get a user-displayable login/identifier for
  # the account.
  def to_s
    email
  end

  # Create a user given a set of omniauth-shibboleth credentials
  # We are persisting: 'uid', 'provider', and 'email' properties
  # @param OmniAuth hash
  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
    end
  end

  # Create a developer/user
  # We are persisting: 'uid', 'provider', and 'email' properties
  # @param Ignoring.
  def self.from_developer(_auth)
    where(provider: 'developer', uid: 'developer').first_or_create do |user|
      user.email = 'developer@uc.edu'
    end
  end
end
