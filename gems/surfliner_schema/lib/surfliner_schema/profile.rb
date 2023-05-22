# frozen_string_literal: true

module SurflinerSchema
  ##
  # A reader profile.
  #
  # All attributes are optional except for +:additional_metadata+, which
  # defaults to an empty hash.
  class Profile < Dry::Struct
    ##
    # The URI which identifies the profile.
    attribute :responsibility, Valkyrie::Types::Coercible::String.optional.default(nil)

    ##
    # A statement identifying the responsibile agent for maintaining the profile.
    attribute :responsibility_statement, Valkyrie::Types::Coercible::String.optional.default(nil)

    ##
    # The human‐readable display label for the profile.
    attribute :date_modified, Valkyrie::Types::Date.optional.default(nil)

    ##
    # The type of objects being described by the profile.
    attribute :type, Valkyrie::Types::Coercible::Symbol.optional.default(nil)

    ##
    # The version string used for the profile.
    attribute :version, Valkyrie::Types::Coercible::String.optional.default(nil)

    ##
    # Additional metadata regarding the profile.
    #
    # This is a catch·all hash for any metadata which isn’t formally supported
    # by Houndstooth.
    attribute :additional_metadata, Valkyrie::Types::Hash.default({}.freeze)
  end
end
