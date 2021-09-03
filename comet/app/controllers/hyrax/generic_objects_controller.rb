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
    self.show_presenter = CometObjectShowPresenter

    # Use a Valkyrie aware form service to generate Valkyrie::ChangeSet style
    # forms.
    self.work_form_service = Hyrax::FormFactory.new

    def available_admin_sets
      admin_set_results = Hyrax.query_service.find_all_of_model(model: Hyrax::AdministrativeSet)

      # get all the templates at once, reducing query load
      templates = PermissionTemplate.where(
        source_id: admin_set_results.map { |p| p.id.to_s }
      ).to_a

      admin_sets = admin_set_results.map do |admin_set_doc|
        template = templates.find { |temp| temp.source_id == admin_set_doc.id.to_s }
        if template.nil?
          Hyrax.logger.warn("Missing permission template for #{admin_set_doc.id}")
          next
        end

        access = Hyrax::PermissionTemplateAccess.where(permission_template_id: template.source_id, agent_id: current_user.email, access: "manage")
        next if access.empty?

        AdminSetSelectionPresenter::OptionsEntry
          .new(admin_set: admin_set_doc, permission_template: template)
      end.compact

      AdminSetSelectionPresenter.new(admin_sets: admin_sets)
    end
  end
end
