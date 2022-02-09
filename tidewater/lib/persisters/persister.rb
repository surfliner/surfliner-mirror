# frozen_string_literal: true

module Persisters
  # Responsible for writing changes from superskunk to the tidewater database
  class Persister
    # Entrypoint method to support both creating and updating OaiItems
    # @param record [Hash] Metadata for a given record from the superskunk api
    def self.create_or_update(record:)
      if find_by_source_iri(record["source_iri"]).nil?
        create(record: record)
      else
        update(record: record)
      end
    end

    # Creates a new OaiItem
    # @param record [Hash] Metadata for a given record from the superskunk api
    def self.create(record:)
      timestamp = DateTime.now.to_s
      record["created_at"] = timestamp
      record["updated_at"] = timestamp
      record["id"] = db.max(:id) + 1

      db.insert(record)
    end

    # Updates an existing OaiItem
    # @param record [Hash] Metadata for a given record from the superskunk api
    def self.update(record:)
      timestamp = DateTime.now.to_s
      record["updated_at"] = timestamp

      # if columns are missing from record, set them to nil as they may have been deleted upstream
      empty_column_values = db.columns.each_with_object({}) { |e, h| h[e] = nil }
      empty_column_values.delete(:id) # internal database identifier should never be updated
      empty_column_values.delete(:created_at) # created timestamp should never be updated
      record.delete(:id) # internal database identifier should never be updated
      record.delete(:created_at) # created timestamp should never be updated
      record.merge!(empty_column_values) { |_k, record_value, _empty_value| record_value }

      db.where(source_iri: record["source_iri"]).update(record)
    end

    # Deletes an OaiItem
    # @param source_iri [String] Unique identifier for an OaiItem
    def self.delete(source_iri:)
      db.where(source_iri: source_iri).delete
    end

    # Find the OaiItem by source_iri
    # @param source_iri [String] Unique identifier for an OaiItem
    def self.find_by_source_iri(source_iri)
      db.first(source_iri: source_iri)
    end

    # Construct a Sequel instance targeting the oai_items database
    # @return [Sequel::Dataset] instance on oai_items table for performing queries
    def self.db
      @db ||= Sequel.postgres(host: ENV["POSTGRES_HOST"],
        port: ENV["POSTGRES_PORT"],
        database: ENV["POSTGRES_DB"],
        user: ENV["POSTGRES_USER"],
        password: ENV["POSTGRES_PASSWORD"])[:oai_items]
    end
  end
end
