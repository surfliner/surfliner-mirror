# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work_resource GenericObject`
module Hyrax
  # Generated controller for GenericObject
  class GenericObjectsController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::GenericObject
    self.show_presenter = CometObjectPresenter

    # Use a Valkyrie aware form service to generate Valkyrie::ChangeSet style
    # forms.
    self.work_form_service = Hyrax::FormFactory.new

    def available_admin_sets
      admin_set_results = Hyrax.query_service.find_all_of_model(model: Hyrax::AdministrativeSet)

      Hyrax.logger.debug "sets: #{admin_set_results.inspect}"

      # get all the templates at once, reducing query load
      templates = PermissionTemplate.where(
        source_id: admin_set_results.map { |p| p.id.to_s }
      ).to_a

      Hyrax.logger.debug "templates: #{templates.inspect}"

      admin_sets = admin_set_results.map do |admin_set_doc|
        template = templates.find { |temp| temp.source_id == admin_set_doc.id.to_s }
        if template.nil?
          Hyrax.logger.warn("Missing permission template for #{admin_set_doc.id}")
          next
        end

        Hyrax.logger.debug "template found: #{template.inspect}"

        access = Hyrax::PermissionTemplateAccess.where(permission_template_id: template.id, agent_id: current_user.user_key, access: Hyrax::PermissionTemplateAccess::MANAGE)

        Hyrax.logger.debug "access calculated for #{current_user}: #{access.inspect}"

        next if access.empty?

        AdminSetSelectionPresenter::OptionsEntry
          .new(admin_set: admin_set_doc, permission_template: template)
      end.compact

      Hyrax.logger.debug "permitted adminsets for #{current_user}: #{admin_sets.inspect}"

      AdminSetSelectionPresenter.new(admin_sets: admin_sets)
    end

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
      CometIiifManifestPresenter.new(search_result_document(id: params[:id])).tap do |p|
        p.hostname = request.base_url
        p.ability = current_ability
      end
    end
  end
end
