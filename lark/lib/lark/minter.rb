# frozen_string_literal: true

require 'ezid-client'

module Lark
  ##
  # This service is responsible for creating unique identifier for an Authority record
  #
  # @example
  #   minter = Minter.mint
  #
  class Minter
    ##
    # @raise [Ezid::Error]
    # @return [String]
    def self.mint
      if ENV.fetch('EZID_ENABLED', '').eql? 'true'
        Ezid::Identifier.mint.to_s
      else
        SecureRandom.uuid
      end
    end
  end
end
