# frozen_string_literal: true

module Persisters
  # Responsible for writing changes from superskunk to oai_set_entries table in the tidewater database
  class SuperskunkSetEntryPersister
    include Persisters::PersisterBase

    # Creates new OaiSetEntry record
    #
    # @param set_source_iri [String] source_iri for the OaiSet
    # @param item_source_iri [String] source_iri for the OaiItem
    # @return [integer] the record id
    def self.create(set_source_iri:, item_source_iri:)
      db.insert(build_set_entry(set_source_iri: set_source_iri, item_source_iri: item_source_iri))
    end

    # Deletes an OaiSetEntry records by OaiSet source iri
    #
    # @param set_source_iri [String] source_iri of the OaiSet
    # @return [integer]
    def self.delete_entries(set_source_iri:)
      oai_set = SuperskunkSetPersister.find_by_source_iri(set_source_iri)

      db.where(oai_set_id: oai_set[:id]).delete
    end

    # Find the OaiItem's by OaiSet source_iri
    # @param source_iri [String] source iri of the OaiSet
    # @return [Array] the OaiSetEntry records
    def self.find_by_set_source_iri(set_source_iri:)
      oai_set = SuperskunkSetPersister.find_by_source_iri(set_source_iri)

      db.where(oai_set_id: oai_set[:id]).to_a
    end

    class << self
      # Build attributes for OaiSetEntry
      #
      # @param set_source_iri [String] source_iri for the OaiSet
      # @param item_source_iri [String] source_iri for the OaiItem
      # @return [Hash] properties for the OaiSetEntry record
      def build_set_entry(set_source_iri:, item_source_iri:)
        timestamp = DateTime.now.to_s

        {}.tap do |record|
          record["created_at"] = timestamp
          record["updated_at"] = timestamp
          record["id"] = (db.max(:id) || 0) + 1

          record["oai_set_id"] = SuperskunkSetPersister.find_by_source_iri(set_source_iri)[:id]
          record["oai_item_id"] = SuperskunkPersister.find_by_source_iri(item_source_iri)[:id]
        end
      end

      # Construct a Sequel instance targeting the oai_set_entries dataset
      # @return [Sequel::Dataset] instance on oai_set_entries table for performing queries
      def db
        @db ||= db_connection[:oai_set_entries]
      end
    end
  end
end
