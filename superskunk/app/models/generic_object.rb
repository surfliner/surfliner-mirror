class GenericObject < Valkyrie::Resource
  # § Defined by Hyrax::Resource:
  attribute :alternate_ids, Valkyrie::Types::Array.of(Valkyrie::Types::ID)

  # § Defined by Hyrax::Work:
  attribute :title, Valkyrie::Types::Array.of(Valkyrie::Types::String)
  attribute :member_of_collection_ids, Valkyrie::Types::Set.of(Valkyrie::Types::ID)

  # § Defined by Comet:
  attribute :ark, Valkyrie::Types::ID

  # § Defined by schema:
  # Provides the attribute definitions:
  include SurflinerSchema::Schema(:generic_object, loader: ::EnvSchemaLoader.new)
  # Provides :mapped_to method:
  include SurflinerSchema::Mappings(:generic_object, loader: ::EnvSchemaLoader.new)
end
