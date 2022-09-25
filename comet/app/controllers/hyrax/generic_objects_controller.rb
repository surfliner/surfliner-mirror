# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work_resource GenericObject`
module Hyrax
  # Generated controller for GenericObject
  class GenericObjectsController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include WithAdminSetSelection
    self.curation_concern_type = ::GenericObject
    self.show_presenter = CometObjectPresenter

    # Use a Valkyrie aware form service to generate Valkyrie::ChangeSet style
    # forms.
    self.work_form_service = Hyrax::FormFactory.new

    def unpublish
      raise(NotImplementedError) unless
        Rails.application.config.feature_collection_publish

      Hyrax.publisher.publish("object.unpublish",
        object: @curation_concern,
        user: current_user)

      redirect_to(main_app.hyrax_generic_object_path(id: params[:id]),
        notice: t("hyrax.base.show_actions.unpublish.success"))
    end

    ##
    # Delete an object
    def destroy
      transactions["work_resource.destroy"]
        .with_step_args("work_resource.delete" => {user: current_user})
        .call(curation_concern)
        .value!

      title = Array(curation_concern.title).first

      after_destroy_response(title)
    end

    def iiif_manifest_presenter
      # todo: load_and_authorize_resource instead
      resource = Hyrax.query_service.find_by(id: params["id"])

      CometIiifManifestPresenter.new(resource).tap do |p|
        p.hostname = request.base_url
        p.ability = current_ability
      end
    end
  end
end
