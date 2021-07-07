# frozen_string_literal: true

class GenericObject < Hyrax::Work
  attribute :ark, Valkyrie::Types::ID

  Comet::Application.config.metadata_models.each do |m|
    include Hyrax::Schema(m)
  end
end
