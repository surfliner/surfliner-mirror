# frozen_string_literal: true

module Hyrax
  module Dashboard
    class CollectionsController < Hyrax::My::CollectionsController
      with_themed_layout "dashboard"
      before_action :authenticate_user!

      def new
        @collection = Hyrax::PcdmCollection
          .new(collection_type_gid: collection_type.to_global_id)
        @form = CollectionForm.new(@collection)
      end

      def create
        permitted = params.require(:pcdm_collection).permit(:title)
        Hyrax.logger.debug(permitted)
        @collection = Hyrax::PcdmCollection.new
        @form = CollectionForm.new(@collection)

        @form.validate(permitted) &&
          collection = Hyrax.persister.save(resource: @form.sync)

        redirect_to(dashboard_collection_path(collection),
          notice: t("hyrax.dashboard.my.action.collection_create_success"))
      end

      def edit
        @collection = Hyrax.query_service.find_by(id: params[:id])
        @form = CollectionForm.new(@collection)
      end

      private

      def collection_type
        id = params[:collection_type_id].presence || default_collection_type.idy

        Hyrax::CollectionType.find(id)
      end
    end
  end
end
