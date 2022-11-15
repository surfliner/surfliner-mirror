# frozen_string_literal: true

##
# Base resource class for those classes defined in M3.
class Resource < Hyrax::Work
  attribute :ark, Valkyrie::Types::ID

  ##
  # Catalog controller depends on it
  # @note uses the @model's `._to_partial_path` if implemented, otherwise
  #   constructs a default
  def to_partial_path
    return @model._to_partial_path if
      @model.respond_to?(:_to_partial_path)

    "hyrax/#{model_name.collection}/#{model_name.element}"
  end
end
