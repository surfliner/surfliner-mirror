class User < ApplicationRecord
  include Spotlight::User
  if Blacklight::Utils.needs_attr_accessible?
    attr_accessible :email
  end

  # Connects this user object to Blacklights Bookmarks.
  include Blacklight::User

  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :trackable,
         :validatable

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
end
