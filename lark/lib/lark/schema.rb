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
      "#{self.class}(#{schema_name})"
    end

    def included(descendent)
      super
      define_attributes(descendent)
    end

    private

    def define_attributes(model)
      schema_config.each do |definition|
        term = definition.keys.first

        model.attribute term.underscore.to_sym,
                        type_for(range: definition[term]['range']['uri'])
      end

      model.attribute :scheme, Valkyrie::Types::Strict::String.default(model::SCHEMA)
    end

    def schema_config
      YAML.load_file(File.expand_path("../../model/#{schema_name}.yml", __dir__))
    end

    def type_for(range:)
      case range
      when 'xsd:anyURI'
        Valkyrie::Types::Set.of(Valkyrie::Types::URI)
      else
        Valkyrie::Types::Set
      end
    end
  end
end
