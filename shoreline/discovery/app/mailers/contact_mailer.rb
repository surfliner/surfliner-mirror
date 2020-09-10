# frozen_string_literal: true

# contact mailer
class ContactMailer < ApplicationMailer
  def contact(contact_form)
    @contact_form = contact_form
    # Check for spam
    return if @contact_form.spam?

    logger.debug("Sending contact form email with: #{@contact_form.headers}")
    mail(@contact_form.headers)
  end
end
