# frozen_string_literal: true

##
# @see lark.rb
module Lark
  def self.Schema(schema_name)
    Schema.new(schema_name)
  end

  ##
  # @note use `Lark::Schema(:name)`
  class Schema < Module
    ##
    # @!attribute [r] schema_name
    #   @return [Symbol]
    attr_reader :schema_name

    ##
    # @param [Symbol] schema_name
    def initialize(schema_name)
      @schema_name = schema_name
      super()
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

    def each_property
      return enum_for(:each_property) unless block_given?

      schema_config.each { |c| yield Property.from_config(c) }
    end

    ##
    # @api private
    class Property
      ##
      # @!attribute [rw] name
      #   @return [Symbol]
      # @!attribute [rw] cardinality
      #   @return [Range]
      # @!attribute [rw] predicate
      #   @return [RDF::URI]
      # @!attribute [rw] range
      #   @return [Dry::Types::Type]
      attr_accessor :name, :cardinality, :definition, :predicate, :range

      ##
      # @param name [Symbol] a snake_case name/method name for the property
      def initialize(name:)
        self.name = name
      end

      ##
      # @return [Boolean]
      def required?
        !cardinality.cover?(0)
      end

      ##
      # @todo replace with #from_m3
      #
      # @param config [Hash] a flat-style Lark configuration entry
      #
      # @return [Property] a property derived from the given configuration
      def self.from_config(config)
        key = config.keys.first

        new(name: key.underscore.to_sym).tap do |property|
          cardinality_match = config[key].fetch("cardinality", "0..*").to_s.match(/^(\d+)\.{2}?(\d+)?/)

          property.cardinality = Range.new(cardinality_match[1]&.to_i, cardinality_match[2]&.to_i)
          property.definition = config[key].fetch("definition", "")
          property.predicate = RDF::URI.intern(config[key].fetch("predicate"))
          property.range = type_for(range: config[key].fetch("range"))
        end
      end

      ##
      # @return [Dry::Types::Type]
      def self.type_for(range:)
        case range
        when "xsd:anyURI"
          Valkyrie::Types::Set.of(Valkyrie::Types::URI)
        else
          Valkyrie::Types::Set
        end
      end
    end

    private

    def define_attributes(model)
      each_property { |property| model.attribute(property.name, property.range) }

      model.attribute(:scheme, Valkyrie::Types::Strict::String.default(model::SCHEMA))
    end

    def schema_config
      YAML.load_file(File.expand_path("../../model/#{schema_name}.yml", __dir__))
    end
  end
end
