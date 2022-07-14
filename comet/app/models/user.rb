class User < ApplicationRecord
  # Connects this user object to Hydra behaviors.
  include Hydra::User
  # Connects this user object to Hyrax behaviors.
  include Hyrax::User
  include Hyrax::UserUsageStats

  if Blacklight::Utils.needs_attr_accessible?
    attr_accessible :email, :password, :password_confirmation
  end
  # Connects this user object to Blacklights Bookmarks.
  include Blacklight::User

  devise :omniauthable, omniauth_providers: [
    :developer,
    :google_oauth2
  ]

  # Method added by Blacklight; Blacklight uses #to_s on your
  # user class to get a user-displayable login/identifier for
  # the account.
  def to_s
    email
  end

  #
  # Create a user given a set of omniauth credentials
  # @param auth [OmniAuth::AuthHash]
  # @return [User] user found or created with `auth` properties
  def self.from_omniauth(auth)
    User.find_or_create_by(email: auth.info.email) do |u|
      u.provider = auth.provider
      u.uid = auth.uid
    end
  rescue => e
    logger.error e && return
  end

  ##
  # Override Hyrax's default version of this method, which assumes our user
  # model will have a `password`.
  def self.find_or_create_system_user(user_key)
    User.find_by_user_key(user_key) ||
      User.find_or_create_by!( Hydra.config.user_key_field => user_key, :provider => Devise.omniauth_providers.first)
  end
end
