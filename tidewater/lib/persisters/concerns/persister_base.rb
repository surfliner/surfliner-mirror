# frozen_string_literal: true

require "sequel"

module Persisters
  ##
  # Base class for persisters.
  module PersisterBase
    def self.included(klass)
      klass.extend(ClassMethods)
    end

    module ClassMethods
      # Creates new OAI record
      # @param record [Hash] Metadata for a given record from the superskunk api
      def create(record:)
        timestamp = DateTime.now.to_s
        record["created_at"] = timestamp
        record["updated_at"] = timestamp
        record["id"] = (db.max(:id) || 0) + 1

        db.insert(record)
      end

      # Construct a Sequel connection instance targeting PostgreSQL database
      # @return Sequel Postgres databse connection instance
      def db_connection
        @db_connection ||= Sequel.postgres(host: ENV["POSTGRESQL_HOST"],
          port: ENV["POSTGRESQL_PORT"],
          database: ENV["POSTGRESQL_DATABASE"],
          user: ENV["POSTGRESQL_USERNAME"],
          password: ENV["POSTGRESQL_PASSWORD"])
      end
    end
  end
end
