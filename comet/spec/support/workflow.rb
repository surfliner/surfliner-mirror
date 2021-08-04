# Provision the various resources necessary to test a workflow for a given user
#
# @param user [User] The user to grant workflow permissions to
def setup_workflow_for(user)
  project = Hyrax::AdministrativeSet.new(title: "Test Project")
  project = Hyrax.persister.save(resource: project)
  Hyrax.index_adapter.save(resource: project)
  permission_template = Hyrax::PermissionTemplate.find_or_create_by!(source_id: project.id.to_s)
  Hyrax::Workflow::WorkflowImporter.load_workflows(logger: Logger.new($stdout))
  workflow = Sipity::Workflow.find_by!(name: workflow_name, permission_template: permission_template)
  Sipity::Workflow
    .activate!(permission_template: permission_template, workflow_name: "surfliner_default")
  Hyrax::Workflow::PermissionGenerator.call(roles: "reviewer", workflow: workflow, agents: user)
  Hyrax::PermissionTemplateAccess.find_or_create_by!(
    permission_template: permission_template,
    agent_type: "user",
    agent_id: user.user_key,
    access: Hyrax::PermissionTemplateAccess::MANAGE
  )
end
