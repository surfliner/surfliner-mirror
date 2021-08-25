# frozen_string_literal: true

# rubocop:disable RSpec/MessageSpies

require "rails_helper"

RSpec.describe ContactFormController do
  let(:required_params) do
    {
      name: "Rose Tyler",
      email: "rose@timetraveler.org",
      subject: "The Doctor",
      message: "Run."
    }
  end

  describe "#new" do
    subject { response }

    before { get :new }

    it { is_expected.to be_successful }
  end

  describe "#create" do
    subject { flash }

    before { post :create, params: {contact_form: params} }

    context "with the required parameters" do
      let(:params) { required_params }

      its(:notice) { is_expected.to eq("Thank you for your message!") }
    end

    context "without a name" do
      let(:params) { required_params.except(:name) }

      its([:error]) do
        is_expected.to eq("Sorry, this message was not sent successfully. " \
                          "Name can't be blank")
      end
    end

    context "without an email" do
      let(:params) { required_params.except(:email) }

      its([:error]) do
        is_expected.to eq("Sorry, this message was not sent successfully. " \
                          "Email can't be blank")
      end
    end

    context "without a subject" do
      let(:params) { required_params.except(:subject) }

      its([:error]) do
        is_expected.to eq("Sorry, this message was not sent successfully. " \
                          "Subject can't be blank")
      end
    end

    context "without a message" do
      let(:params) { required_params.except(:message) }

      its([:error]) do
        is_expected.to eq("Sorry, this message was not sent successfully. " \
                          "Message can't be blank")
      end
    end

    context "with an invalid email" do
      let(:params) { required_params.merge(email: "bad-wolf") }

      its([:error]) do
        is_expected.to eq("Sorry, this message was not sent successfully. " \
                          "Email is invalid")
      end
    end
  end

  describe "#after_deliver" do
    context "with a successful email" do
      it "calls #after_deliver" do
        expect(controller).to receive(:after_deliver)

        post :create, params: {contact_form: required_params}
      end
    end

    context "with an unsuccessful email" do
      it "does not call #after_deliver" do
        expect(controller).not_to receive(:after_deliver)

        post :create, params: {contact_form: required_params.except(:email)}
      end
    end
  end

  context "when encoutering a RuntimeError" do
    let(:logger) { instance_double("Rails::Logger", info?: true) }

    before do
      allow(controller).to receive(:logger).and_return(logger)
      allow(ContactMailer).to receive(:contact).and_raise(RuntimeError)
    end

    it "is logged via Rails" do
      expect(logger)
        .to receive(:error)
        .with("Contact form failed to send: #<RuntimeError: RuntimeError>")

      post :create, params: {contact_form: required_params}
    end
  end
end

# rubocop:enable RSpec/MessageSpies
