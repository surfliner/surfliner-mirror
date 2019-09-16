# frozen_string_literal: true

class User < ApplicationRecord
  include Spotlight::User
  attr_accessible :email if Blacklight::Utils.needs_attr_accessible?

  # Devise Invitable tries to set a password, but we're not using passwords for Omniauth
  # So this is a dummy/noop attribute
  attr_accessor :password unless ENV["AUTH_METHOD"] == "database"

  # Connects this user object to Blacklights Bookmarks.
  include Blacklight::User

  if ENV["AUTH_METHOD"] == "database"
    devise :database_authenticatable,
           :registerable,
           :recoverable,
           :rememberable,
           :trackable,
           :invitable,
           :validatable
  else
    devise :invitable,
           :trackable,
           :omniauthable, omniauth_providers: [
             :developer,
             :google_oauth2,
           ]
  end

  # avoid setting new users as superadmins
  def add_default_roles; end

  # Override this Spotlight method since we're using Google for auth and
  # don't need to invite people to create accounts
  def invite_pending?
    return false unless ENV["AUTH_METHOD"] == "database"

    super
  end

  # Method added by Blacklight; Blacklight uses #to_s on your
  # user class to get a user-displayable login/identifier for
  # the account.
  def to_s
    email
  end

  # Create a user given a set of omniauth credentials
  # @param auth [OmniAuth::AuthHash]
  # @return [User] user found or created with `auth` properties
  def self.from_omniauth(auth)
    invited_user = User.find_by(email: auth.info.email)
    if invited_user&.created_by_invite?
      # these properties need to be manually set; a find_and_create_by block (as
      # below) will skip setting them, since the invited account itself already
      # exists in skeleton form
      invited_user.provider = auth.provider
      invited_user.uid = auth.uid
      invited_user.save
      invited_user
    else # existing user or new (un-invited) account
      User.find_or_create_by(email: auth.info.email) do |u|
        u.provider = auth.provider
        u.uid = auth.uid
      end
    end
  rescue StandardError => e
    logger.error e && return
  end
end
