class EnvSchemaLoader < SurflinerSchema::Loader
  def self.default_schemas
    ENV["METADATA_MODELS"].to_s.split(",").map(&:to_sym)
  end

  def self.search_paths
    SurflinerSchema::Loader.search_paths + [
      File.join(Rails.root, "..")
    ]
  end
end
