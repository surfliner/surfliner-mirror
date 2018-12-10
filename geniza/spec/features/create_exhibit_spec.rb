# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Import and Display a Work', :clean, js: true do
  include Warden::Test::Helpers

  let(:csv_file_path)   { File.join(fixture_path, csv_file_name) }
  let(:csv_file_name)   { 'url_single_item_exhibit.csv' }
  let(:site_admin)      { FactoryBot.create(:site_admin) }

  before do
    allow(Spotlight::DefaultThumbnailJob).to receive(:perform_later)
    login_as site_admin
  end

  context 'Create an exhibit' do
    it 'creates and populates an exhibit via the UI' do
      expect(Spotlight::Exhibit.count).to eq 0
      visit '/'
      click_link site_admin.user_key
      click_link 'Create new exhibit'
      fill_in('Title', with: 'Test Exhibit')
      fill_in('Tag list', with: 'testing')
      click_button 'Save'
      expect(page).to have_content 'The exhibit was created.'
      expect(Spotlight::Exhibit.count).to eq 1
      exhibit = Spotlight::Exhibit.first
      expect(exhibit.title).to eq 'Test Exhibit'
      visit('/spotlight/test-exhibit/resources/new')
      click_link 'Upload multiple items'
      expect(page).to have_content 'CSV File'
      page.attach_file('resources_csv_upload[url]', csv_file_path)
      click_button 'Add item'
      visit '/spotlight/test-exhibit/catalog?utf8=%E2%9C%93&exhibit_id=test-exhibit&search_field=all_fields&q='
      expect(page).to have_content 'A Cute Dog'
    end
  end
end
