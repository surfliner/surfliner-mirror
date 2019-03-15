# frozen_string_literal: true

require "sitemap_generator"

SitemapGenerator::Sitemap.default_host = ENV.fetch("SITEMAP_DEFAULT_HOST")

# Use /public/sitemaps to reuse directory across capistrano deploys
SitemapGenerator::Sitemap.sitemaps_path = "sitemaps/"

SitemapGenerator::Interpreter.send :include, Rails.application.routes.url_helpers
SitemapGenerator::Interpreter.send :include, Spotlight::Engine.routes.url_helpers

SitemapGenerator::Sitemap.create do
  Spotlight::Sitemap.add_all_exhibits(self)
end
