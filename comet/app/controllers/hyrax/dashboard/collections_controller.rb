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
        permitted = params.require(:pcdm_collection).permit(title: [])
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
          Hyrax::CollectionPresenter.new(@collection, current_ability)
      end

      private

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
