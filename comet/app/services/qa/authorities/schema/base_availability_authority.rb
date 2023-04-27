# frozen_string_literal: true

module Qa
  module Authorities
    module Schema
      ##
      # Base class for “availability” (super)subauthorities.
      #
      # Do not use this class directly; instead use
      # +Qa::Authorities::Schema.subauthority_for+ to get a class tailored to a
      # specific availability.
      class BaseAvailabilityAuthority
        class << self
          include Qa::Authorities::AuthorityWithSubAuthority

          ##
          # The available subauthorities, which is to say, controlled values
          # properties within this schema availability.
          def subauthorities
            loader.properties_for(availability).values.filter_map { |prop|
              next if prop.controlled_values.nil?
              prop.name.to_s
            }
          end

          ##
          # A +Qa::Authorities::Schema::BasePropertyAuthority+ subclass
          # tailored to this schema availability and the provided property name.
          def subauthority_class(name)
            property_name = name.to_sym
            @subauthorities ||= {}
            return @subauthorities[property_name] if @subauthorities.include?(property_name)
            subauthority = Class.new(
              Qa::Authorities::Schema::BasePropertyAuthority
            ) do
              class << self
                attr_reader :availability
                attr_reader :loader
                attr_reader :property_name

                def inspect
                  "Qa::Authorities::Schema.subauthority_class(#{availability.inspect}).subauthority_class(#{property_name.inspect})"
                end
              end
            end
            subauthority.instance_variable_set(:@availability, availability)
            subauthority.instance_variable_set(:@loader, loader)
            subauthority.instance_variable_set(:@property_name, property_name)
            @subauthorities[property_name] = subauthority
          end

          ##
          # The schema availability of this authority. Overridden in subclasses.
          def availability
            raise NotImplementedError, ".availability must be implemented on a subclass."
          end

          ##
          # The schema loader of this authority. Overridden in subclasses.
          def loader
            raise NotImplementedError, ".loader must be implemented on a subclass."
          end
        end
      end
    end
  end
end
