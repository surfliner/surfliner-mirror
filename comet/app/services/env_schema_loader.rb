# frozen_string_literal: true

# this class overrides the standard schema loader to read schema names from the
# environment, instead of taking an argument
class EnvSchemaLoader < SurflinerSchema::HyraxLoader
  def initialize(availability: :generic_object)
    super(
      *ENV["METADATA_MODELS"].to_s.split(",").map { |schema|
        self.class.loader_class.instance.load(schema.to_sym)
      },
      availability: availability
    )
  end
end
