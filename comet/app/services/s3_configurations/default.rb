module S3Configurations
  class Default
    def self.access_key
      ENV.slice("REPOSITORY_S3_ACCESS_KEY",
        "MINIO_ACCESS_KEY",
        "MINIO_ROOT_USER").values.first
    end

    def self.secret_key
      ENV.slice("REPOSITORY_S3_SECRET_KEY",
        "MINIO_SECRET_KEY",
        "MINIO_ROOT_PASSWORD").values.first
    end

    def self.bucket
      ENV.fetch("REPOSITORY_S3_BUCKET") { "comet#{Rails.env}" }
    end

    def self.region
      ENV.fetch("REPOSITORY_S3_REGION", "us-east-1")
    end

    def self.endpoint
      "#{ENV.fetch("MINIO_PROTOCOL", "http")}://#{ENV["MINIO_ENDPOINT"]}:#{ENV.fetch("MINIO_PORT", 9000)}"
    end

    def self.minio?
      ENV["MINIO_ENDPOINT"].present?
    end

    def self.present?
      access_key.present? && secret_key.present?
    end
  end
end
