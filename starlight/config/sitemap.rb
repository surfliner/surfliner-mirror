# frozen_string_literal: true

if ENV["SITEMAPS_ENABLED"].present?
  require "aws-sdk-s3"
  require "sitemap_generator"

  if ENV["S3_ENDPOINT"].present?
    # Horrible hack to get Minio working for now
    # Minio requires the force_path_style option to be set
    # see: https://github.com/kjvarga/sitemap_generator/pull/351
    SitemapGenerator::AwsSdkAdapter.class_eval do
      def s3_resource_options
        options = {}
        options[:force_path_style] = true # Minio requirement
        options[:region] = @aws_region if !@aws_region.nil?
        options[:endpoint] = @aws_endpoint if !@aws_endpoint.nil?
        if !@aws_access_key_id.nil? && !@aws_secret_access_key.nil?
          options[:credentials] = Aws::Credentials.new(
            @aws_access_key_id,
            @aws_secret_access_key
          )
        end
        options
      end
      # rubocop:enable Style/NegatedIf
    end

    SitemapGenerator::Sitemap.adapter = SitemapGenerator::AwsSdkAdapter.new(
      ENV["S3_BUCKET_NAME"],
      aws_access_key_id: ENV["AWS_ACCESS_KEY_ID"],
      aws_secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"],
      aws_region: ENV["AWS_REGION"],
      aws_endpoint: ENV["S3_ENDPOINT"]
    )
  else
    SitemapGenerator::Sitemap.adapter = SitemapGenerator::AwsSdkAdapter.new(
      ENV["S3_BUCKET_NAME"],
      aws_access_key_id: ENV["AWS_ACCESS_KEY_ID"],
      aws_secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"],
      aws_region: ENV["AWS_REGION"]
    )
  end

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
