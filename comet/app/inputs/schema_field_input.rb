##
# A SimpleForm input field for SurflinerSchema‐defined properties.
class SchemaFieldInput < MultiValueInput
  # Override so the JS can find the element.
  def input_type
    "multi_value"
  end
end
