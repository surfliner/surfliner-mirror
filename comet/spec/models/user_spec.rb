# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  let(:google_auth_hash) do
    OmniAuth::AuthHash.new(
      provider: "google_oauth2",
      uid: "drseuss",
      info: {"email" => "google_oauth2@uc.edu"}
    )
  end

  let(:invited_user_google_auth_hash) do
    OmniAuth::AuthHash.new(
      provider: "google_oauth2",
      uid: "a-user-that-does-not-exist",
      info: {"email" => "a-user-that-does-not-exist@uc.edu"}
    )
  end

  let(:dev_auth_hash) do
    OmniAuth::AuthHash.new(
      provider: "developer",
      uid: "developer@uc.edu",
      info: {"email" => "developer@uc.edu"}
    )
  end

  let(:invalid_google_auth_hash_missing_info) do
    OmniAuth::AuthHash.new(
      provider: "google_oauth2",
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

  describe ".from_omniauth for Google strategy" do
    it "creates a User when a user is first authenticated" do
      user = described_class.from_omniauth(google_auth_hash)
      expect(user).to be_persisted
      expect(user.provider).to eq("google_oauth2")
      expect(user.uid).to eq("drseuss")
      expect(user.email).to eq("google_oauth2@uc.edu")
    end

    it "does not persist a google response with bad or missing information" do
      described_class.from_omniauth(invalid_google_auth_hash_missing_info)
      expect(described_class.find_by(uid: "test", provider: "google_oauth2")).to be nil
    end
  end

  describe "comet role" do
    context "with public user" do
      it "has no comet group role" do
        user = described_class.new

        expect(user.groups).not_to include(Comet::PERMISSION_TEXT_VALUE_COMET)
      end
    end

    context "with login user" do
      it "assigns comet group role to developer" do
        user = described_class.from_omniauth(dev_auth_hash)
        expect(user).to be_persisted

        expect(user.groups).to include(Comet::PERMISSION_TEXT_VALUE_COMET)
      end

      it "assigns comet group role to user with google_auth" do
        user = described_class.from_omniauth(google_auth_hash)
        expect(user).to be_persisted

        expect(user.groups).to include(Comet::PERMISSION_TEXT_VALUE_COMET)
      end
    end
  end

  describe "campus role" do
    context "with public user" do
      it "has no campus group role" do
        user = described_class.new

        expect(user.groups).not_to include(Comet::PERMISSION_TEXT_VALUE_CAMPUS)
      end
    end

    context "with login user" do
      it "assigns campus group role to developer" do
        user = described_class.new(provider: "campus")

        expect(user.groups).to include(Comet::PERMISSION_TEXT_VALUE_CAMPUS)
      end

      it "assigns campus group role to developer" do
        user = described_class.new(provider: "campus")

        expect(user.groups).to include(Comet::PERMISSION_TEXT_VALUE_CAMPUS)
      end

      it "assigns campus group role to user with google_auth" do
        user = described_class.new(provider: "campus")

        expect(user.groups).to include(Comet::PERMISSION_TEXT_VALUE_CAMPUS)
      end
    end
  end
end
