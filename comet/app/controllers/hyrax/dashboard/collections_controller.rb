# frozen_string_literal: true

module Hyrax
  module Dashboard
    class CollectionsController < ApplicationController
      with_themed_layout "dashboard"
      before_action :authenticate_user!

      load_and_authorize_resource(only: [:show, :publish],
        class: Hyrax::PcdmCollection,
        instance_name: :collection)

      rescue_from Hydra::AccessDenied, CanCan::AccessDenied, with: :deny_collection_access

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

      def destroy
        @collection = Hyrax.query_service.find_by(id: params[:id])

        destroyed = transactions["collection_resource.destroy"].call(@collection).value!
        Hyrax.logger.debug("Destroyed Collection: #{destroyed}")

        respond_to do |format|
          format.html do
            redirect_to hyrax.my_collections_path,
              notice: t("hyrax.dashboard.my.action.collection_delete_success")
          end
          format.json { head :no_content, location: hyrax.my_collections_path }
        end
      rescue => err
        Hyrax.logger.error(err)

        respond_to do |format|
          format.html do
            flash[:notice] = t("hyrax.dashboard.my.action.collection_delete_fail")
            render :edit, status: :unprocessable_entity
          end
          format.json { render json: {id: id}, status: :unprocessable_entity, location: dashboard_collection_path(@collection) }
        end
      end

      def edit
        @collection = Hyrax.query_service.find_by(id: params[:id])
        @collection_type = collection_type
        @form = CollectionForm.new(@collection)
        @form.prepopulate!
      end

      def show
        @presenter =
          Hyrax::CollectionPresenter.new(curation_concern, current_ability)
        query_collection_members
      end

      def update
        form = CollectionForm.new(Hyrax.query_service.find_by(id: params[:id]))

        return after_create_errors(form) unless
          form.validate(collection_params)

        @collection = transactions["change_set.update_collection"]
          .call(form)
          .value_or { |failure| after_update_errors(failure.first) }

        respond_to do |format|
          format.html { redirect_to dashboard_collection_path(@collection), notice: t("hyrax.dashboard.my.action.collection_update_success") }
          format.json { render json: @collection, status: :updated, location: dashboard_collection_path(@collection) }
        end
      end

      def repository
        blacklight_config.repository || Blacklight::Solr::Repository.new(blacklight_config)
      end

      ##
      # Publish the collection to a discovery system.
      def publish
        raise(NotImplementedError) unless
          Rails.application.config.feature_collection_publish

        Hyrax.logger.debug { "Publishing collection #{@collection} on request of #{current_user}." }

        Hyrax.publisher.publish("collection.publish",
          collection: @collection,
          user: current_user)
        redirect_to(hyrax.dashboard_collection_path(curation_concern))
      end

      private

      def after_create_errors(form)
        errors = []

        form.errors.messages.each do |fld, err|
          errors << "#{fld} #{err.to_sentence}"
        end

        respond_to do |wants|
          wants.html do
            flash[:error] = errors.to_sentence.to_s
            render "new", status: :unprocessable_entity
          end
          wants.json do
            render_json_response(response_type: :unprocessable_entity, options: {errors: errors.to_sentence})
          end
        end
      end

      def collection_params
        params.permit(collection: {})[:collection]
          .merge(params.permit(:collection_type_gid)
                   .with_defaults(collection_type_gid: default_collection_type_gid))
          .merge(member_of_collection_ids: Array(params[:parent_id]))
      end

      def deny_collection_access(exception)
        Hyrax.logger.info(exception)
        head :unauthorized
      end

      def query_collection_members
        member_works
        member_subcollections if collection_type.nestable?
        parent_collections if collection_type.nestable? && action_name == "show"
      end

      # Instantiate the membership query service
      def collection_member_service
        @collection_member_service ||= Collections::CollectionMemberSearchService.new(scope: self, collection: @presenter, params: params_for_query, search_builder_class: CometCollectionMemberSearchBuilder)
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

      def default_collection_type_gid
        default_collection_type.to_global_id.to_s
      end
    end
  end
end
