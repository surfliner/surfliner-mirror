# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  let(:shib_auth_hash) do
    OmniAuth::AuthHash.new(
      provider: "shibboleth",
      uid: "drseuss",
      info: { "email" => "shibboleth@uc.edu" }
    )
  end

  let(:invited_user_shib_auth_hash) do
    OmniAuth::AuthHash.new(
      provider: "shibboleth",
      uid: "a-user-that-does-not-exist",
      info: { "email" => "a-user-that-does-not-exist@uc.edu" }
    )
  end

  let(:dev_auth_hash) do
    OmniAuth::AuthHash.new(
      provider: "developer",
      uid: "developer@uc.edu",
      info: { "email" => "developer@uc.edu" }
    )
  end

  let(:invalid_shib_auth_hash_missing_info) do
    OmniAuth::AuthHash.new(
      provider: "shibboleth",
      uid: "test"
    )
  end

  describe ".from_omniauth for Developer strategy" do
    it "creates a User for first time user" do
      user = described_class.from_omniauth(dev_auth_hash)

      expect(user).to be_persisted
      expect(user.provider).to eq("developer")
      expect(user.email).to eq("developer@uc.edu")
    end
  end

  describe ".from_omniauth for Shibboleth strategy" do
    it "creates a User when a user is first authenticated" do
      user = described_class.from_omniauth(shib_auth_hash)
      expect(user).to be_persisted
      expect(user.provider).to eq("shibboleth")
      expect(user.uid).to eq("drseuss")
      expect(user.email).to eq("shibboleth@uc.edu")
    end

    it "creates a User that has been invited" do
      described_class.invite!(email: "a-user-that-does-not-exist@uc.edu", skip_invitation: true)
      user = described_class.from_omniauth(invited_user_shib_auth_hash)
      expect(user).to be_persisted
      expect(user.provider).to eq("shibboleth")
      expect(user.uid).to eq("a-user-that-does-not-exist")
      expect(user.email).to eq("a-user-that-does-not-exist@uc.edu")
    end

    it "does not persist a shib response with bad or missing information" do
      described_class.from_omniauth(invalid_shib_auth_hash_missing_info)
      expect(described_class.find_by(uid: "test", provider: "shibboleth")).to be nil
    end
  end

  describe ".invite! from Devise invitable" do
    it "can invite users" do
      expect { described_class.invite!(email: "a-user-that-does-not-exist@uc.edu", skip_invitation: true) }.not_to raise_error
      expect(described_class.last.provider).to be_nil
      expect(described_class.last.uid).to be_nil
      expect(described_class.last.email).to eq "a-user-that-does-not-exist@uc.edu"
      expect(described_class.last.invite_pending?).to eq false
    end
  end
end
