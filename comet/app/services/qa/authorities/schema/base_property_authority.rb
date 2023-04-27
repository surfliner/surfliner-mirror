# frozen_string_literal: true

module Qa
  module Authorities
    module Schema
      ##
      # Base class for property subauthorities.
      #
      # Do not use this class directly; instead use
      # +Qa::Authorities::Schema.property_authority_for+ to get a class tailored
      # to a property in a given availability.
      class BasePropertyAuthority < Qa::Authorities::Base
        ##
        # All the controlled values in this property.
        def all
          terms
        end

        ##
        # Find the value of a property by ID or URL.
        def find(id_or_url)
          v = id_or_url.to_s
          terms.find { |term| term[:id] == v || term[:uri] == v } || {}
        end

        ##
        # Search for a term by its label.
        def search(v)
          v.blank? ? [] : terms.select { |term|
            /\b#{v.downcase(:fold)}/.match(term[:label].downcase(:fold))
          }
        end

        ##
        # The schema availability of this authority.
        def availability
          self.class.availability
        end

        ##
        # The schema loader of this authority.
        def loader
          self.class.loader
        end

        ##
        # The property name for this authority.
        def property_name
          self.class.property_name
        end

        ##
        # The property definition for this authority.
        def property
          @property ||= loader.properties_for(availability)[property_name]
        end

        private

        ##
        # The terms corresponding to this schema availability and property name.
        def terms
          return @terms if @terms
          @terms = []
          return @terms unless property
          cv = property.controlled_values
          # todo: the remote values
          @terms += cv.values.values.map { |val|
            {id: val.name.to_s, label: val.display_label.to_s, active: true, uri: val.iri.to_s}
          }
        end

        public

        class << self
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

          ##
          # The property name for this authority. Overridden in subclasses.
          def property_name
            raise NotImplementedError, ".property_name must be implemented on a subclass."
          end
        end
      end
    end
  end
end
