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
      ENV["SITEMAPS_HOST"] = "https://s3-us-west-2.amazonaws.com/mybucket/"
    end

    after do
      ENV.delete("ALLOW_ROBOTS")
      ENV.delete("SITEMAPS_ENABLED")
      ENV.delete("SITEMAPS_HOST")
    end

    it "specifies a Sitemap entry in the robots.txt file" do
      visit "/robots.txt"
      expect(page).to have_content("Sitemap: https://s3-us-west-2.amazonaws.com/mybucket/sitemaps/sitemap.xml.gz")
    end
  end

  context "with sitemaps disabled" do
    it "does not specify a Sitemap entry in the robots.txt file" do
      visit "/robots.txt"
      expect(page).to have_no_content("Sitemap:")
    end
  end
end
