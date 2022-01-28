# An OAI-PMH item.
#
# OAI-PMH records can be generated using the `to_{metadata_prefix}` methods.
# <https://github.com/code4lib/ruby-oai/blob/3cdc12d86c7d1dde00b47105a7dab6def3f6801d/lib/oai/provider.rb#L209-L232>.
class OaiItem < ApplicationRecord
  # The fifteen elements defined in the original Dublin Core 1.1 Elements namespace, stored as fields in our database.
  def self.dc_elements
    OAI::Provider::Metadata::DublinCore.instance.fields
  end

  # `type` is a DC term, so the inheritance column needs to be something different.
  self.inheritance_column = :subclass_type

  # The fields in our database which contain XML (potentially delimited with U+FFFF).
  def self.xml_fields
    dc_elements
  end

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
      return [] unless self.class.dc_elements.include? field

      # This is a defined Dublin Core element; get it from the model.
      # Dublin Core elements are stored directly in the database as strings, with multiple values delimited by U+FFFF.
      values_from_field(send(field).to_s)
    else
      # TODO: Other kinds of metadata terms?
      []
    end
  end

  # Returns a <oai_dc:dc> element containing the Dublin Core metadata for this item.
  def to_oai_dc
    result = Nokogiri::XML::Builder.new do |xml|
      xml["oai_dc"].dc(
        "xmlns:oai_dc" => "http://www.openarchives.org/OAI/2.0/oai_dc/",
        "xmlns:dc" => "http://purl.org/dc/elements/1.1/",
        "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
        "xsi:schemaLocation" =>
          "http://www.openarchives.org/OAI/2.0/oai_dc/ "\
          "http://www.openarchives.org/OAI/2.0/oai_dc.xsd"
      ) do
        self.class.dc_elements.each do |field|
          values = metadata_for("http://purl.org/dc/elements/1.1/#{field}")
          values.each do |value|
            xml["dc"].send(field, value)
          end
        end
      end
    end
    result.doc.to_xml
  end

  private

  # Splits the provided text on U+FFFF and replaces any characters not allowed in XML documents with U+FFFD.
  #
  # @param text [String] the text value of the field
  # @return [Array<String>] values which can be inserted into an XML document
  def values_from_field(text)
    text.split("\uFFFF", -1).map do |uncool|
      uncool.gsub(/[\x00-\x08\x0B\x0C\x0E-\x1F\uFFFE\uFFFF]/, "\uFFFD")
    end
  end
end
