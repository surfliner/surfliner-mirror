# frozen_string_literal: true

module Hyrax
  ##
  # Base controller for M3‐defined resources.
  #
  # This class is extended in the Hyrax initializer to define specific
  # controllers for each M3 class.
  class ResourcesController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include WithAdminSetSelection
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

    def remove_member
      if !params["member_id"].present?
        redirect_to(main_app.hyrax_generic_object_path(id: params[:id]),
          alert: t("hyrax.base.component_actions.remove.component_missing"))
        return
      end

      member_ids = curation_concern.member_ids.dup.map(&:id)

      work_member_ids = {}
      member_ids.each_with_index do |v, i|
        work_member_ids[i.to_s] = {}
        work_member_ids[i.to_s]["id"] = v
        work_member_ids[i.to_s]["_destroy"] = v.to_i == params["member_id"].to_i ? "true" : "false"
      end

      transactions["change_set.update_work"]
        .with_step_args("work_resource.update_work_members" => {work_members_attributes: work_member_ids, user: current_user})
        .call(Hyrax::ChangeSet.for(curation_concern))
        .value!

      redirect_to(main_app.hyrax_generic_object_path(id: params[:id]),
        notice: t("hyrax.base.component_actions.remove.success"))
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
