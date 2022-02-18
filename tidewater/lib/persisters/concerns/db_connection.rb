# frozen_string_literal: true

require "sequel"

module Persisters
  ##
  # Module for Sequel Postgres database support.
  module DbConnection
    def self.included(klass)
      klass.extend(ClassMethods)
    end

    module ClassMethods
      # Construct a Sequel connection instance targeting PostgreSQL database
      # @return Sequel Postgres databse connection instance
      def db_connection
        @db_connection ||= Sequel.postgres(host: ENV["POSTGRES_HOST"],
          port: ENV["POSTGRES_PORT"],
          database: ENV["POSTGRES_DB"],
          user: ENV["POSTGRES_USER"],
          password: ENV["POSTGRES_PASSWORD"])
      end
    end
  end
end
