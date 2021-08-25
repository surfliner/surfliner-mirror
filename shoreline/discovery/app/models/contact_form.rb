# frozen_string_literal: true

# contact form model
class ContactForm
  include ActiveModel::Model
  attr_accessor :contact_method, :name, :email, :subject, :message
  validates :email, :name, :subject, :message, presence: true
  validates :email, format: /\A([\w.%+\-]+)@([\w\-]+\.)+(\w{2,})\z/i,
                    allow_blank: true

  # - can't use this without ActiveRecord::Base validates_inclusion_of
  # :category, in: self.class.issue_types_for_locale

  # They should not have filled out the `contact_method' field.
  # That's there to prevent spam.
  def spam?
    contact_method.present?
  end

  # Declare the e-mail headers. It accepts anything the mail method
  # in ActionMailer accepts.
  def headers
    {
      subject: subject,
      to: ENV["CONTACT_EMAIL"],
      from: ENV["CONTACT_EMAIL"],
      cc: email
    }
  end
end
