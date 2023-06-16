module S3Configurations
  class StagingArea
    def self.access_key
      ENV.slice("STAGING_AREA_REPOSITORY_S3_ACCESS_KEY",
        "STAGING_AREA_MINIO_ACCESS_KEY",
        "STAGING_AREA_MINIO_ROOT_USER").values.first
    end

    def self.secret_key
      ENV.slice("STAGING_AREA_REPOSITORY_S3_SECRET_KEY",
        "STAGING_AREA_MINIO_SECRET_KEY",
        "STAGING_AREA_MINIO_ROOT_PASSWORD").values.first
    end

    def self.bucket
      ENV.fetch("STAGING_AREA_S3_BUCKET") { "comet#{Rails.env}" }
    end

    def self.region
      ENV.fetch("STAGING_AREA_REPOSITORY_S3_REGION", "us-east-1")
    end

    def self.endpoint
      "#{ENV.fetch("STAGING_AREA_MINIO_PROTOCOL", "http")}://#{ENV["STAGING_AREA_MINIO_ENDPOINT"]}:#{ENV.fetch("STAGING_AREA_MINIO_PORT", 9000)}"
    end

    def self.minio?
      ENV["STAGING_AREA_MINIO_ENDPOINT"].present?
    end

    def self.present?
      access_key.present? && secret_key.present?
    end
  end
end
