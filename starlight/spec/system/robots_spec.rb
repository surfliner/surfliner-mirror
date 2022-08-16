# frozen_string_literal: true

require "rails_helper"

RSpec.describe "robots", type: :system do
  context "with a production environment" do
    before { ENV["ALLOW_ROBOTS"] = "true" }

    after { ENV.delete("ALLOW_ROBOTS") }

    it "allows robots" do
      visit "/robots.txt"
      expect(page).to have_content("User-Agent: *")
      expect(page).to have_content("Allow: /")
      expect(page).to have_content("Disallow: /sidekiq")
    end
  end

  context "with a non-production environment" do
    it "does not allow robots" do
      visit "/robots.txt"
      expect(page).to have_content("User-Agent: *")
      expect(page).to have_content("Disallow: /")
    end
  end

  context "with sitemaps enabled" do
    before do
      ENV["ALLOW_ROBOTS"] = "true"
      ENV["SITEMAPS_ENABLED"] = "true"
      ENV["S3_BUCKET_NAME"] = "starlight"
    end

    after do
      ENV.delete("ALLOW_ROBOTS")
      ENV.delete("SITEMAPS_ENABLED")
      ENV.delete("S3_BUCKET_NAME")
    end

    it "specifies a Sitemap entry in the robots.txt file" do
      visit "/robots.txt"
      expect(page).to have_content("Sitemap: #{ENV["SITEMAPS_HOST"]}sitemaps/sitemap.xml.gz")
    end

    it "successfully writes the sitemap to an S3-compatible bucket" do
      SitemapGenerator::Interpreter.run
      s3 = Aws::S3::Resource.new(endpoint: ENV["S3_ENDPOINT"], force_path_style: true)
      bucket = s3.bucket(ENV["S3_BUCKET_NAME"])
      expect(bucket.object("sitemaps/sitemap.xml.gz").exists?).to be_truthy
    end
  end

  context "with sitemaps disabled" do
    it "does not specify a Sitemap entry in the robots.txt file" do
      visit "/robots.txt"
      expect(page).to have_no_content("Sitemap:")
    end
  end
end
