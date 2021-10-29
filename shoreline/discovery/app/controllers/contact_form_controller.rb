# contact form controller
class ContactFormController < ApplicationController
  before_action :build_contact_form

  def new
  end

  def create
    if @contact_form.valid? # a valid form is probably not spam
      deliver!
      @contact_form = ContactForm.new
    else
      flash_form_invalid_message
    end
    render :new
  rescue RuntimeError => e
    handle_create_exception(e)
  end

  def handle_create_exception(exception)
    logger.error("Contact form failed to send: #{exception.inspect}")
    flash.now[:error] = "Sorry, this message was not delivered. " \
                        "#{@contact_form.errors.full_messages.first}"
    render :new
  end

  # Override this method if you want to perform additional operations
  # when a email is successfully sent, such as sending a confirmation
  # response to the user.
  def after_deliver
  end

  private

  def build_contact_form
    @contact_form = ContactForm.new(contact_form_params)
  end

  def contact_form_params
    return {} unless params.key?(:contact_form)

    params
      .require(:contact_form)
      .permit(:contact_method, :name, :email, :subject, :message)
  end

  def deliver!
    ContactMailer.contact(@contact_form).deliver_now
    flash.now[:notice] = "Thank you for your message!"
    after_deliver
  end

  def flash_form_invalid_message
    flash.now[:error] = "Sorry, this message was not sent successfully. "
    flash.now[:error] <<
      @contact_form.errors.full_messages.map(&:to_s).join(", ")
  end
end
# rubocop:enable Style/FrozenStringLiteralComment
