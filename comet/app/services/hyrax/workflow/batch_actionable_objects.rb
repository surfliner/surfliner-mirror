# frozen_string_literal: true

module Hyrax
  module Workflow
    ##
    # Extend ActionableObjects to retrieve a list of workflow-ready objects for a given user.
    # Results are given as a presenter objects with SolrDocument-like behavior, with added
    # support for workflow states.
    #
    # @example
    #   Hyrax::Workflow::BatchActionableObjects.new(user: current_user).each do |object|
    #     puts object.title
    #     puts object.workflow_state
    #   end
    #
    # @see Hyrax::Workflow::ObjectInWorkflowDecorator
    class BatchActionableObjects < ActionableObjects
      ##
      # @!attribute [rw] batch
      #   @return [String]
      attr_accessor :q, :batch_id

      ##
      # @param [::User] user the user whose
      def initialize(user:, q:, batch_id:)
        super(user: user)
        @q = q
        @batch_id = batch_id
      end

      ##
      # @return [Hyrax::Workflow::ObjectInWorkflowDecorator]
      def each
        return enum_for(:each) unless block_given?
        ids_and_states = id_state_pairs
        return if ids_and_states.none?

        docs = Hyrax::SolrQueryService.new.with_ids(ids: ids_and_states.map(&:first)).solr_documents

        # Filter docs results by title
        docs = docs.select { |doc| doc.title.first.downcase.include?(q.downcase) } unless q.blank?

        docs.each do |solr_doc|
          object = ObjectInWorkflowDecorator.new(solr_doc)
          _, state = ids_and_states.find { |id, _| id == object.id }

          object.workflow_state = state

          yield object
        end
      end

      private

      ##
      # @api private
      # @return [Array[String, Sipity::WorkflowState]]
      def id_state_pairs
        gids_and_states = PermissionQuery
          .scope_entities_for_the_user(user: user)
          .pluck(:id, :proxy_for_global_id, :workflow_state_id)

        # Filter workflow by batch
        gids_and_states = gids_and_states.select { |gs| entities_in_batch.include?(gs[0]) } unless batch_id.blank?
        return [] if gids_and_states.none?

        all_states = Sipity::WorkflowState.find(gids_and_states.map(&:last).uniq)

        gids_and_states.map do |id, str, state_id|
          [GlobalID.new(str).model_id,
            all_states.find { |state| state.id == state_id }]
        end
      end

      ##
      # Determine whether the batch id exists
      def batch_exist?(id:)
        return false if id.nil?
        BatchUpload.where(batch_id: id).any?
      end

      ##
      # Find all Sipty:Entity ID in the batch
      # @return [[Integer]]
      def entities_in_batch
        BatchUploadEntry.joins("INNER JOIN batch_uploads t ON batch_upload_id = t.id WHERE t.batch_id ='#{batch_id}'")
          .order("batch_upload_entries.created_at desc")
          .map { |r| r.entity_id }
      end
    end
  end
end
