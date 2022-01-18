# frozen_string_literal: true

module Hyrax
  module Dashboard
    class CollectionsController < ApplicationController
      with_themed_layout "dashboard"
      before_action :authenticate_user!

      load_and_authorize_resource(only: :show,
        class: Hyrax::PcdmCollection,
        instance_name: :collection)

      def new
        @collection = Hyrax::PcdmCollection
          .new(collection_type_gid: collection_type.to_global_id)
        @form = CollectionForm.new(@collection)
      end

      def create
        permitted = params.require(:collection).permit(title: [])
        permitted = permitted.merge(collection_type_gid: params.require(:collection_type_gid))
        permitted = permitted.merge(depositor: current_user.user_key)
        Hyrax.logger.debug(permitted)
        @collection = Hyrax::PcdmCollection.new

        @form = CollectionForm.new(@collection)

        if @form.validate(permitted)
          collection = Hyrax.persister.save(resource: @form.sync)
          Hyrax::Collections::PermissionsCreateService.create_default(collection: collection, creating_user: current_user)
          collection.permission_manager.read_users += [current_user.user_key]
          collection.permission_manager.acl.save
          Hyrax.logger.debug("collection.permission_manager edit groups and users after PermissionsCreateService")
          Hyrax.logger.debug(collection.permission_manager.edit_groups.to_a)
          Hyrax.logger.debug(collection.permission_manager.edit_users.to_a)
          Hyrax.index_adapter.save(resource: collection)
        end

        redirect_to(my_collections_path,
          notice: t("hyrax.dashboard.my.action.collection_create_success"))
      end

      def edit
        @collection = Hyrax.query_service.find_by(id: params[:id])
        @form = CollectionForm.new(@collection)
      end

      def show
        @presenter =
          Hyrax::CollectionPresenter.new(curation_concern, current_ability)
        query_collection_members
      end

      def repository
        blacklight_config.repository || Blacklight::Solr::Repository.new(blacklight_config)
      end

      private

      def query_collection_members
        member_works
        member_subcollections if collection_type.nestable?
        parent_collections if collection_type.nestable? && action_name == "show"
      end

      # Instantiate the membership query service
      def collection_member_service
        @collection_member_service ||= Collections::CollectionMemberSearchService.new(scope: self, collection: @presenter, params: params_for_query)
      end

      # You can override this method if you need to provide additional
      # inputs to the search builder. For example:
      #   search_field: 'all_fields'
      # @return <Hash> the inputs required for the collection member search builder
      def params_for_query
        params.merge(q: params[:cq])
      end

      def member_works
        @response = collection_member_service.available_member_works
        @member_docs = @response.documents
        @members_count = @response.total
      end

      def member_subcollections
        results = collection_member_service.available_member_subcollections
        @subcollection_solr_response = results
        @subcollection_docs = results.documents
        @subcollection_count = @presenter.nil? ? 0 : @subcollection_count = @presenter.subcollection_count = results.total
      end

      def parent_collections
        page = params[:parent_collection_page].to_i
        query = Hyrax::Collections::NestedCollectionQueryService
        @presenter.parent_collections = query.parent_collections(child: @collection, scope: self, page: page)
      end

      def curation_concern
        # Query Solr for the collection.
        # run the solr query to find the collection members
        response, _docs = single_item_search_service.search_results
        curation_concern = response.documents.first
        raise CanCan::AccessDenied unless curation_concern
        curation_concern
      end

      def single_item_search_service
        Hyrax::SearchService.new(config: blacklight_config, user_params: params.except(:q, :page), scope: self, search_builder_class: SingleCollectionSearchBuilder)
      end

      # Instantiates the search builder that builds a query for a single item
      # this is useful in the show view.
      def single_item_search_builder
        search_service.search_builder
      end

      def collection_type
        id = params[:collection_type_id].presence || default_collection_type.id

        Hyrax::CollectionType.find(id)
      end

      def default_collection_type
        Hyrax::CollectionType.find_or_create_default_collection_type
      end
    end
  end
end
