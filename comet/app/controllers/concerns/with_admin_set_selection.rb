# frozen_string_literal: true

module WithAdminSetSelection
  ##
  # List the admin sets available to +#current_user+, wrapped with
  # +Hyrax::AdminSetSelectionPresenter+.
  def available_admin_sets
    admin_set_results = Hyrax.query_service.find_all_of_model(model: Hyrax::AdministrativeSet)

    Hyrax.logger.debug "sets: #{admin_set_results.inspect}"

    # get all the templates at once, reducing query load
    templates = Hyrax::PermissionTemplate.where(
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

      Hyrax::AdminSetSelectionPresenter::OptionsEntry
        .new(admin_set: admin_set_doc, permission_template: template)
    end.compact

    Hyrax.logger.debug "permitted adminsets for #{current_user}: #{admin_sets.inspect}"

    Hyrax::AdminSetSelectionPresenter.new(admin_sets: admin_sets)
  end
end
