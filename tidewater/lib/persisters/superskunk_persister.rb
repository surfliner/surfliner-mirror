# frozen_string_literal: true

require_relative "concerns/persister_base"
require_relative "concerns/superskunk_persister_base"

module Persisters
  # Responsible for writing changes from superskunk to oai_items table in tidewater database
  class SuperskunkPersister
    include Persisters::PersisterBase
    include Persisters::SuperskunkPersisterBase

    class << self
      # Construct a Sequel instance targeting the oai_items dataset
      # @return [Sequel::Dataset] instance on oai_items table for performing queries
      def db
        @db ||= db_connection[:oai_items]
      end
    end
  end
end
