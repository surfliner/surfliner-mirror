# frozen_string_literal: true

require "ezid-client"

module Lark
  ##
  # A minter that hits the EZID API
  class EzidMinter
    ##
    # @return [String]
    # @raise [Ezid::Error]
    def mint
      Ezid::Identifier.mint.to_s
    rescue Ezid::Error => e
      raise Minter::MinterError, e.message
    end
  end
end
