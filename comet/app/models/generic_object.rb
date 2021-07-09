# frozen_string_literal: true

class GenericObject < Hyrax::Work
  attribute :ark, Valkyrie::Types::ID

  include Hyrax::Schema(:noop, schema_loader: ::EnvSchemaLoader.new)
end
