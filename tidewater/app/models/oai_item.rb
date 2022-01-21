class OaiItem < ApplicationRecord

  # The fifteen elements defined in the original Dublin Core 1.1 Elements namespace, which are stored as fields in our database.
  def self.dc_elements
    OAI::Provider::Metadata::DublinCore.instance.fields
  end

  # The fields in our database which contain XML (potentially delimited with U+FFFF).
  def self.xml_fields
    self.dc_elements
  end

  # Ensure that each of the passed fields does not contain any characters not allowed in XML 1.0, save U+FFFF, which is used to delimit multiple values.
  validates *self.xml_fields, format: {
    without: /[\x00-\x08\x0B\x0C\x0E-\x1F\uFFFE]/,
    message: "must be representable in XML"
  }

  # Gets the metadata associated with a given URI, if such metadata exists in the database.
  #
  # Always returns an array of strings. If no term is found, the array will be empty.
  #
  # @param uri [String] the URI for the metadata term
  # @return [Array<String>] defined values for the metadata term
  def metadata_for(uri)
    if uri.start_with? "http://purl.org/dc/elements/1.1/"
      # This URI is in the Dublin Core elements namespace.
      field = uri.delete_prefix("http://purl.org/dc/elements/1.1/").to_sym
      if self.class.dc_elements.include? field
        # This is a defined Dublin Core element; get it from the model.
        # Dublin Core elements are stored directly in the database as strings, with multiple instances delimited by "\uFFFF".
        return self.send(field).to_s.split("\uFFFF", -1)
      else
        # This is not a defined Dublin Core element.
        return []
      end
    else
      # TODO: Other kinds of metadata terms?
      return []
    end
  end

end
