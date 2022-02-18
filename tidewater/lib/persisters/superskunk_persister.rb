# frozen_string_literal: true

require_relative "concerns/db_connection"
require_relative "concerns/superskunk_persister_base"

module Persisters
  # Responsible for writing changes from superskunk to oai_items table in tidewater database
  class SuperskunkPersister
    include Persisters::DbConnection
    include Persisters::SuperskunkPersisterBase

    # Construct a Sequel instance targeting the oai_items database
    # @return [Sequel::Dataset] instance on oai_items table for performing queries
    def self.db
      @db ||= db_connection[:oai_items]
    end
  end
end
