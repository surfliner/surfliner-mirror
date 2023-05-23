# frozen_string_literal: true

##
# Finds FileMetadata objects by #file_identifier for the sequel adapter.
module Superskunk
  module CustomQueries
    class FindFileMetadata
      def self.queries
        [:find_file_metadata]
      end

      def initialize(query_service:)
        @query_service = query_service
      end

      attr_reader :query_service

      def find_file_metadata(file_id)
        query_json = {file_identifier: [{id: file_id.to_s}]}.to_json
        refs = query_service.run_query(query_service.send(:find_inverse_references_query), query_json)
        refs.first || raise(Valkyrie::Persistence::ObjectNotFoundError)
      end
    end
  end
end
