# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Search", type: :system, js: true do
  it 'returns search results' do
    visit "/"
    expect(page).to have_content('Search Comet')
  end
end
