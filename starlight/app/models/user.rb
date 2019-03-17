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
    devise :trackable, :omniauthable, omniauth_providers: [:shibboleth, :developer]
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

  # Create a user given a set of omniauth credentials
  # We are persisting: 'uid', 'provider', and 'email' properties
  # See: https://github.com/omniauth/omniauth/wiki/Auth-Hash-Schema
  # See: https://github.com/toyokazu/omniauth-shibboleth/#setup-shibboleth-strategy (Shibboleth Strategy)
  # See: https://github.com/omniauth/omniauth/blob/master/lib/omniauth/strategies/developer.rb (Dev Strategy)
  # @param auth [OmniAuth::AuthHash]
  # @return [User] user found or created with `auth` properties
  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
    end
  rescue StandardError => e
    logger.error e && return
  end
end
