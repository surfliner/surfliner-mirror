# frozen_string_literal: true

require 'ezid-client'

module Lark
  ##
  # This service is responsible for creating unique identifier for an Authority record
  #
  # @example
  #   minter = Minter.new
  #   minter.mint
  #
  class Minter
    ##
    # Minter factory
    #
    # @param [Symbol] a minter type
    # @return [#mint]
    def self.for(type)
      case type
      when :ezid
        EzidMinter.new
      when :uuid
        new
      else
        raise ArgumentError, "Unknown minter/id type: #{type}"
      end
    end

    ##
    # @return [String]
    # @raise [Ezid::Error]
    def mint
      SecureRandom.uuid
    end
  end

  ##
  # A minter that hits the EZID API
  class EzidMinter
    ##
    # @return [String]
    # @raise [Ezid::Error]
    def mint
      Ezid::Identifier.mint.to_s
    end
  end
end
