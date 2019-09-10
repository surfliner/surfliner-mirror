# frozen_string_literal: true

require "rails_helper"

RSpec.describe DatabaseURL do
  describe "#build" do
    subject { described_class.build(env) }

    describe "when using a non-default sqlite location" do
      let(:env) do
        { "DB_ADAPTER" => "sqlite3",
          "DATABASE_URL" => "sqlite3:nonstandard/db/location.sqlite3", }
      end

      it "produces the correct db url string" do
        expect(subject).to eq("sqlite3:nonstandard/db/location.sqlite3")
      end
    end

    describe "defaulting to the standard sqlite location" do
      let(:env) do
        { "DB_ADAPTER" => "sqlite3" }
      end

      it "produces the correct db url string" do
        expect(subject).to eq("sqlite3:db/test.sqlite3")
      end
    end

    describe "parsing DATABASE_URL" do
      let(:env) do
        { "DATABASE_URL" => "postgresql://db_user@localhost:80/starlight" }
      end

      it "produces the correct db url string" do
        expect(subject).to eq("postgresql://db_user@localhost:80/starlight")
      end
    end

    describe "overriding DATABASE_URL with POSTGRES_ vars" do
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
