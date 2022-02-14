# frozen_string_literal: true

require "singleton"

class EnvSchemaReader < SurflinerSchema::Reader
  include Singleton

  def initialize
    super(*ENV["METADATA_MODELS"].to_s.split(",").map(&:to_sym))
  end
end
