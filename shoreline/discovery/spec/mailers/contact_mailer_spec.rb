# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ContactMailer do
  let(:user) { create(:user) }
  let(:required_params) do
    {
      name: 'Rose Tyler',
      email: 'rose@timetraveler.org',
      subject: 'The Doctor',
      message: 'Run.'
    }
  end
  let(:contact_form) { ContactForm.new(required_params) }
  let(:email) { described_class.contact(contact_form).deliver_now }

  it 'renders the subject' do
    expect(email.subject).to eql(contact_form.subject)
  end

  it 'renders the receiver email' do
    expect(email.to).to eql([ENV['CONTACT_EMAIL']])
  end

  it 'renders the sender email' do
    expect(email.from).to eql([ENV['CONTACT_EMAIL']])
  end

  it 'renders the cc email for the user' do
    expect(email.cc).to eql([contact_form.email])
  end

  it 'renders the message body' do
    expect(email.body.encoded).to match(contact_form.message)
  end
end
