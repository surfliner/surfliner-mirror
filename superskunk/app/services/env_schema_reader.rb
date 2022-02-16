require "singleton"

class EnvSchemaReader < SurflinerSchema::Reader
  include Singleton

  def initialize
    super(*ENV["METADATA_MODELS"].to_s.split(",").map(&:to_sym))
  end

  def self.search_paths
    SurflinerSchema::Reader.search_paths + [
      File.join(Rails.root, "..")
    ]
  end
end
