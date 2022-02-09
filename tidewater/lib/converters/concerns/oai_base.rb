# frozen_string_literal: true

module Converters
  ##
  # Convert attributes for OAI-PMH item.
  module OaiBase
    def self.included(klass)
      klass.extend(ClassMethods)
    end

    module ClassMethods
      ##
      # The fifteen elements defined in the original Dublin Core 1.1 Elements namespace, stored as fields in our database.
      def dc_elements
        OAI::Provider::Metadata::DublinCore.instance.fields
      end

      # Replaces any characters not allowed in XML 1.0 documents with U+FFFD.
      #
      # @param text [String] the text to sanitize
      # @return [String] the sanitized value
      def sanitize_value(text)
        text.gsub(/[\x00-\x08\x0B\x0C\x0E-\x1F\uFFFE\uFFFF]/, "\uFFFD")
      end
    end
  end
end
