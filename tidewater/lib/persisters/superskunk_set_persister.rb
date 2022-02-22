# frozen_string_literal: true

module Persisters
  # Responsible for writing changes from superskunk to oai_sets table in the tidewater database
  class SuperskunkSetPersister
    include Persisters::PersisterBase
    include Persisters::SuperskunkPersisterBase

    class << self
      # Construct a Sequel instance targeting the oai_sets dataset
      # @return [Sequel::Dataset] instance on oai_sets table for performing queries
      def db
        @db ||= db_connection[:oai_sets]
      end
    end
  end
end
