class GenericObject < Valkyrie::Resource
  attribute :title, Valkyrie::Types::String.default("abc")
end
