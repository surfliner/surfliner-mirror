# frozen_string_literal: true

class GenericObject < Hyrax::Work
  attribute :ark, Valkyrie::Types::ID

  include SurflinerSchema::Schema(:generic_object, loader: ::EnvSchemaLoader.instance)
end
