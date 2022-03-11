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
  attributes(
    **{}.merge(
      *EnvSchemaLoader.instance.load_all.map { |reader|
        reader.to_struct_attributes(availability: :generic_object)
      }
    )
  )
end
