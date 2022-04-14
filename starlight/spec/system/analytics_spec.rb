# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Analytics", :clean, type: :system, js: true do
  let(:site_admin) { FactoryBot.create(:omniauth_site_admin) }

  before do
    omniauth_setup_dev_auth_for(site_admin)
    sign_in
  end

  it "does not show Analytics link in the Admin dashboard" do
    visit "/"
    click_link site_admin.user_key
    click_link "Create new exhibit"
    fill_in("Title", with: "Test Exhibit")
    click_button "Create Exhibit"
    expect(page).to have_content "The exhibit was created."
    visit "/starlight/test-exhibit/dashboard"
    expect(page).not_to have_link("Analytics")
  end
end
