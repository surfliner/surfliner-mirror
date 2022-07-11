class GenericObject < Valkyrie::Resource
  #  ____________________________
  # | Defined by Hyrax::Resource |
  #  ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
  attribute :alternate_ids, Valkyrie::Types::Array.of(Valkyrie::Types::ID)

  #  ________________________
  # | Defined by Hyrax::Work |
  #  ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
  attribute :title, Valkyrie::Types::Array.of(Valkyrie::Types::String)

  #  __________________
  # | Defined by Comet |
  #  ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
  attribute :ark, Valkyrie::Types::ID

  #  ________________________
  # | Defined by environment |
  #  ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
  # Provides the attribute definitions:
  include SurflinerSchema::Schema(:generic_object, loader: ::EnvSchemaLoader.new)
  # Provides :mapped_to method:
  include SurflinerSchema::Mappings(:generic_object, loader: ::EnvSchemaLoader.new)
end
