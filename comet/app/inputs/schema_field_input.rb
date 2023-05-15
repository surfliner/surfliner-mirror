# frozen_string_literal: true

##
# A SimpleForm input field for SurflinerSchema‐defined properties.
class SchemaFieldInput < MultiValueInput
  attr_reader :availability, :definition

  def initialize(builder, attribute_name, column, input_type, options = {})
    @availability = options.delete(:availability)
    @definition = options.delete(:definition)
    options.merge!({
      label: definition.display_label,
      hint: definition.definition,
      usage_guidelines: definition.usage_guidelines,
      required: definition.required?
    })
    super
  end

  # Override so the JS can find the element.
  def input_type
    "multi_value"
  end

  def authority
    return nil unless definition.controlled_values
    @authority ||= Qa::Authorities::Schema.property_authority_for(
      name: definition.name,
      availability: availability
    )
  end

  def input_dom_id
    input_html_options[:id] || "#{object_name}_#{attribute_name}"
  end

  def label_id
    input_dom_id + "_label"
  end

  private

  def select_options
    return nil unless authority
    @select_options ||= authority.all.map { |element| [element[:label], element[:uri]] }
  end

  def build_field_options(value)
    field_options = input_html_options.dup

    field_options[:value] = value
    if @rendered_first_element
      field_options[:id] = nil
      field_options[:required] = nil
    else
      field_options[:id] ||= input_dom_id
    end
    field_options[:class] ||= []
    field_options[:class] += ["#{input_dom_id} form-control multi-text-field"]
    field_options[:"aria-labelledby"] = label_id
    field_options.delete(:multiple)

    @rendered_first_element = true

    field_options
  end

  def build_field(value, _index)
    if select_options
      # render a select tag
      html_options = build_field_options(value).merge({include_blank: true})
      template.select_tag(attribute_name, template.options_for_select(select_options, value), html_options)
    else
      # render an input tag
      html_options = build_field_options(value)
      @builder.text_field(attribute_name, html_options)
    end
  end
end
