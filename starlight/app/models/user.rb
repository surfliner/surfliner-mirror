# frozen_string_literal: true

class User < ApplicationRecord
  include Spotlight::User
  attr_accessible :email if Blacklight::Utils.needs_attr_accessible?

  # Connects this user object to Blacklights Bookmarks.
  include Blacklight::User

  if ENV["DATABASE_AUTH"].present?
    devise :database_authenticatable,
           :registerable,
           :recoverable,
           :rememberable,
           :trackable,
           :validatable
  else
    devise :trackable, :omniauthable, omniauth_providers: [:shibboleth]
  end

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
  # See: https://github.com/omniauth/omniauth/wiki/Auth-Hash-Schema
  # @param auth [OmniAuth::AuthHash]
  # @return [User] user found or created with `auth` properties
  def self.from_shibboleth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
    end
  rescue StandardError => e
    logger.error e && return
  end

  # Create a developer/user
  # We are persisting: 'uid', 'provider', and 'email' properties
  # @param auth [OmniAuth::AuthHash] Ignored by this method
  # @return [User] user found or created for local development
  def self.from_developer(_auth)
    where(provider: "developer", uid: "developer").first_or_create do |user|
      user.email = "developer@uc.edu"
    end
  end
end
