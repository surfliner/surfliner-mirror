require "singleton"

class EnvSchemaLoader < SurflinerSchema::Loader
  include Singleton

  def load_all
    ENV["METADATA_MODELS"].to_s.split(",").map do |schema|
      load(schema.to_sym)
    end
  end

  def self.search_paths
    SurflinerSchema::Loader.search_paths + [
      File.join(Rails.root, "..")
    ]
  end
end
