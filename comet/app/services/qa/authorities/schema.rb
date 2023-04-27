# frozen_string_literal: true

module Qa
  module Authorities
    ##
    # Base (super)authority for schema controlled values.
    #
    # Use +.subauthority_for+ to get the authority for a given availability
    # (e.g., M3 class), and then +.subauthority_for+ again to get the authority
    # for a property within that availability.
    #
    # Or just use +.property_authority_for+ to do it all in one go.
    module Schema
      class << self
        include Qa::Authorities::AuthorityWithSubAuthority

        ##
        # Get the property subsubauthority for the given name and availability.
        def property_authority_for(name:, availability:)
          subauthority_for(availability.to_s).subauthority_for(name.to_s)
        end

        ##
        # The available subauthorities, which is to say, schema availabilities.
        def subauthorities
          loader.availabilities.map(&:to_s)
        end

        ##
        # A +Qa::Authorities::Schema::BaseAvailabilityAuthority+ subclass
        # tailored to the provided schema availability.
        def subauthority_class(name)
          availability = name.to_sym
          @subauthorities ||= {}
          return @subauthorities[availability] if @subauthorities.include?(availability)
          subauthority = Class.new(
            Qa::Authorities::Schema::BaseAvailabilityAuthority
          ) do
            class << self
              attr_reader :availability
              attr_reader :loader

              def inspect
                "Qa::Authorities::Schema.subauthority_class(#{availability.inspect})"
              end
            end
          end
          subauthority.instance_variable_set(:@availability, availability)
          subauthority.instance_variable_set(:@loader, loader)
          @subauthorities[availability] = subauthority
        end

        ##
        # Returns a +Qa::Authorities::Schema::BaseAvailabilityAuthority+
        # subclass for the given authority if valid, or raises an error
        # otherwise.
        def subauthority_for(subauthority)
          validate_subauthority!(subauthority)
          subauthority_class(subauthority)
        end

        ##
        # The schema loader from which to read controlled values.
        def loader
          @loader ||= ::SchemaLoader.new
        end
      end
    end
  end
end
