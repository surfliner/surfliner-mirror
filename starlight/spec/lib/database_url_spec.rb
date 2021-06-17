# frozen_string_literal: true

require "rails_helper"

RSpec.describe DatabaseURL do
  describe "#build" do
    subject { described_class.build(env, rails_env) }

    describe "parsing DATABASE_URL" do
      let(:rails_env) { "development" }
      let(:env) do
        { "DATABASE_URL" => "postgresql://db_user@localhost:80/starlight" }
      end

      it "produces the correct db url string" do
        expect(subject).to eq("postgresql://db_user@localhost:80/starlight")
      end
    end

    describe "supporting TEST_POSTGRES_DB" do
      let(:rails_env) { "test" }
      let(:env) do
        {
          "DATABASE_URL" => "sqlite3:db/development.sqlite3",
          "DB_ADAPTER" => "postgresql",
          "POSTGRES_USER" => "db_user",
          "POSTGRES_PASSWORD" => "apassword",
          "POSTGRES_HOST" => "localhost",
          "POSTGRES_DB" => "starlight",
          "TEST_POSTGRES_DB" => "starlight_test",
        }
      end

      it "produces the correct db url string" do
        expect(subject).to eq("postgresql://db_user:apassword@localhost/starlight_test")
      end
    end

    describe "overriding DATABASE_URL with POSTGRES_ vars" do
      let(:rails_env) { "development" }
      let(:env) do
        {
          "DATABASE_URL" => "sqlite3:db/development.sqlite3",
          "DB_ADAPTER" => "postgresql",
          "POSTGRES_USER" => "db_user",
          "POSTGRES_PASSWORD" => "apassword",
          "POSTGRES_HOST" => "localhost",
          "POSTGRES_DB" => "starlight",
        }
      end

      it "produces the correct db url string" do
        expect(subject).to eq("postgresql://db_user:apassword@localhost/starlight")
      end
    end
  end
end
