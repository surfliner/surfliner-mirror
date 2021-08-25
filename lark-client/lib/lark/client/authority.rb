# frozen_string_literal: true

require "dry-struct"

module Lark
  module Client
    ##
    # Types for Authority values
    module Types
      include Dry::Types.module
    end

    ##
    # @see https://github.com/dry-rb/dry-struct
    class Authority < Dry::Struct
      attribute :type, Types::Strict::Symbol.default(:concept)

      attribute :pref_label, Types::Strict::String
    end
  end
end
