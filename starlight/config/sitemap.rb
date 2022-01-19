# frozen_string_literal: true

if ENV["SITEMAPS_ENABLED"].present?
  require "aws-sdk-s3"
  require "sitemap_generator"

  minio_config_options =
    if ENV["S3_ENDPOINT"].present?
      {aws_endpoint: ENV["S3_ENDPOINT"], force_path_style: true}
    else
      {}
    end

  SitemapGenerator::Sitemap.adapter = SitemapGenerator::AwsSdkAdapter.new(
    ENV["S3_BUCKET_NAME"],
    aws_access_key_id: ENV["AWS_ACCESS_KEY_ID"],
    aws_secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"],
    aws_region: ENV["AWS_REGION"],
    **minio_config_options
  )

  SitemapGenerator::Sitemap.default_host = ENV.fetch("APP_URL")

  # The remote host where your sitemaps will be hosted
  SitemapGenerator::Sitemap.sitemaps_host = ENV["SITEMAPS_HOST"]

  # The directory to write sitemaps to locally
  SitemapGenerator::Sitemap.public_path = "tmp/"

  # Write sitemaps to <bucket-name>/sitemaps
  SitemapGenerator::Sitemap.sitemaps_path = "sitemaps/"

  SitemapGenerator::Interpreter.send :include, Rails.application.routes.url_helpers
  SitemapGenerator::Interpreter.send :include, Spotlight::Engine.routes.url_helpers

  SitemapGenerator::Sitemap.create do
    Spotlight::Sitemap.add_all_exhibits(self)
  end
end
