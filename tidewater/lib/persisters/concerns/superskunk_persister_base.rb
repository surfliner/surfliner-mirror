# frozen_string_literal: true

module Persisters
  ##
  # Base class for superskunk persisters, which will persist OAI records like OaiItem and OaiSet.
  module SuperskunkPersisterBase
    def self.included(klass)
      klass.extend(ClassMethods)
    end

    module ClassMethods
      # Entrypoint method to support both creating and updating OAI records
      # @param record [Hash] Metadata for a given record from the superskunk api
      def create_or_update(record:)
        if find_by_source_iri(record["source_iri"]).nil?
          create(record: record)
        else
          update(record: record)
        end
      end

      # Creates new OAI record
      # @param record [Hash] Metadata for a given record from the superskunk api
      def create(record:)
        timestamp = DateTime.now.to_s
        record["created_at"] = timestamp
        record["updated_at"] = timestamp
        record["id"] = (db.max(:id) || 0) + 1

        db.insert(record)
      end

      # Updates an existing OAI record
      # @param record [Hash] Metadata for a given record from the superskunk api
      def update(record:)
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

      # Deletes an OAI record
      # @param source_iri [String] Unique identifier for the OAI record
      def delete(source_iri:)
        db.where(source_iri: source_iri).delete
      end

      # Find the OAI record by source_iri
      # @param source_iri [String] Unique identifier for OAI record
      def find_by_source_iri(source_iri)
        db.first(source_iri: source_iri)
      end
    end
  end
end
