# frozen_string_literal: true

require_relative 'ezid_minter'

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

    class MinterError < RuntimeError; end
  end
end
