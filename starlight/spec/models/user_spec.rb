# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  let(:auth_hash) do
    OmniAuth::AuthHash.new(
      provider: "shibboleth",
      uid: "drseuss",
      info: { "email" => "test@uc.edu" }
    )
  end

  let(:invalid_auth_hash_missing_info) do
    OmniAuth::AuthHash.new(
      provider: "shibboleth",
      uid: "test"
    )
  end

  describe ".from_developer" do
    it "creates a User for first time user" do
      user = User.from_developer(auth_hash)

      expect(user).to be_persisted
      expect(user.provider).to eq("developer")
      expect(user.email).to eq("developer@uc.edu")
    end
  end

  describe ".from_shibboleth" do
    it "creates a User when a user is first authenticated" do
      user = User.from_shibboleth(auth_hash)
      expect(user).to be_persisted
      expect(user.provider).to eq("shibboleth")
      expect(user.uid).to eq("drseuss")
      expect(user.email).to eq("test@uc.edu")
    end

    it "does not persist a shib response with bad or missing information" do
      User.from_shibboleth(invalid_auth_hash_missing_info)
      expect(User.find_by(uid: "test", provider: "shibboleth")).to be nil
    end
  end
end
