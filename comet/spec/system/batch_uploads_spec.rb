# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Collections", type: :system, js: true do
  let(:user) { User.find_or_create_by(email: "comet-admin@library.ucsb.edu") }

  before { sign_in user }

  it "can see the button for batch ingest and load the form" do
    visit "/dashboard"
    click_on "Batch Upload"

    expect(page).to have_content("Add New Works by Batch")

  end
end
