# frozen_string_literal: true

module Lark
  def self.Schema(schema_name)
    Schema.new(schema_name)
  end

  class Schema < Module
    ##
    # @!attribute [r] schema_name
    #   @return [Symbol]
    attr_reader :schema_name

    ##
    # @param [Symbol] schema_name
    def initialize(schema_name)
      @schema_name = schema_name
    end

    ##
    # @return [String]
    def inspect
      "#{self.class}(#{@schema_name})"
    end

    def included(descendent)
      super
      descendent.define_schema(@schema_name)
    end
  end
end
