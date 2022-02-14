# frozen_string_literal: true

# this class overrides the standard schema loader to read schema names from the
# environment, instead of taking an argument
class EnvSchemaLoader < SurflinerSchema::HyraxLoader
  def initialize
    super self.class.reader_class.instance
  end

  def self.reader_class
    EnvSchemaReader
  end
end
