# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Sending an email via the contact form', type: :feature do
  let(:user) { create(:user) }

  it 'sends mail as an anyonymous user' do
    visit '/'
    click_link 'Contact'
    expect(page).to have_content 'Contact Form'
    fill_in 'Your Name', with: 'Test'
    fill_in 'Your Email', with: 'test@example.com'
    fill_in 'Subject', with: 'test subject'
    fill_in 'Message', with: 'I am contacting you regarding Shoreline.'
    click_button 'Send'
    expect(page).to have_content 'Thank you for your message!'
  end

  it 'sends mail as a registered user' do
    sign_in(user)
    visit '/'
    click_link 'Contact'
    expect(page).to have_content 'Contact Form'
    fill_in 'Your Name', with: 'Test'
    fill_in 'Subject', with: 'test subject'

    # email box should be prefilled if user is login
    expect(page).to have_field('contact_form_email', with: user.email)

    fill_in 'Message', with: 'I am contacting you regarding Shoreline.'
    click_button 'Send'
    expect(page).to have_content 'Thank you for your message!'
  end
end
