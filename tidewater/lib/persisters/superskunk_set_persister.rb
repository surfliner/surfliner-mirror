# frozen_string_literal: true

module Persisters
  # Responsible for writing changes from superskunk to the tidewater database
  class SuperskunkSetPersister
    include Persisters::DbConnection
    include Persisters::SuperskunkPersisterBase

    # Construct a Sequel instance targeting the oai_items database
    # @return [Sequel::Dataset] instance on oai_items table for performing queries
    def self.db
      @db ||= db_connection[:oai_sets]
    end
  end
end
