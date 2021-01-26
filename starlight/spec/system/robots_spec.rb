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
end
