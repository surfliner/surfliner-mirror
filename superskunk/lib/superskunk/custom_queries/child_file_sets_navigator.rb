module Superskunk
  module CustomQueries
    ##
    # Navigate from a resource to the child filesets in the resource.
    #
    # @see https://github.com/samvera/valkyrie/wiki/Queries#custom-queries
    # @since 3.4.0
    class ChildFileSetsNavigator
      # Define the queries that can be fulfilled by this navigator.
      def self.queries
        [:find_child_file_sets, :find_child_file_set_ids]
      end

      attr_reader :query_service

      def initialize(query_service:)
        @query_service = query_service
      end

      ##
      # Find child filesets of a given resource, and map to Valkyrie Resources
      #
      # @param [Valkyrie::Resource] resource
      #
      # @return [Array<Valkyrie::Resource>]
      def find_child_file_sets(resource:)
        query_service.find_members(resource: resource).select { |r| r.is_a?(Hyrax::FileSet) }
      end

      ##
      # Find the ids of child filesets of a given resource, and map to Valkyrie Resources IDs
      #
      # @param [Valkyrie::Resource] resource
      #
      # @return [Array<Valkyrie::ID>]
      def find_child_file_set_ids(resource:)
        find_child_file_sets(resource: resource).map(&:id)
      end
    end
  end
end
