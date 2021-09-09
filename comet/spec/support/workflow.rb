# Provision the various resources necessary to test a workflow for a given user
#
# @param user [User] The user to grant workflow permissions to
def setup_workflow_for(user)
  projects = Hyrax.query_service.find_all_of_model(model: Hyrax::AdministrativeSet)

  puts "\n== found projects #{projects}"
  unless (project = projects.find { |p| p.title.include?("Test Project") })
    puts "\n== Creating test project (AdministrativeSet)"
    project = Hyrax::AdministrativeSet.new(title: "Test Project")
    project = Hyrax.persister.save(resource: project)
    Hyrax.index_adapter.save(resource: project)
  end

  puts "\n== Using test set #{project.inspect} for #{user}"

  puts "\n== Ensuring PermissionTemplate for exists for test AdministrativeSet #{project.id}"
  permission_template = Hyrax::PermissionTemplate.find_or_create_by!(source_id: project.id.to_s)

  puts "\n== Using test template #{permission_template.inspect} for #{user}"

  puts "\n== Loading workflows"
  Rake::Task["hyrax:workflow:load"].execute
  puts "\n== Activating surfliner_default workflow"
  Sipity::Workflow
    .activate!(permission_template: permission_template, workflow_name: "surfliner_default")

  puts "\n== Assigning all workflow roles to #{user}"
  Sipity::WorkflowRole.all.each do |wf_role|
    Sipity::WorkflowResponsibility.find_or_create_by!(agent_id: user.to_sipity_agent.id, workflow_role_id: wf_role.id)
  end

  puts "\n== Assigning permissions to #{user}"
  Hyrax::PermissionTemplateAccess.find_or_create_by!(
    permission_template: permission_template,
    agent_type: "user",
    agent_id: user.user_key,
    access: Hyrax::PermissionTemplateAccess::MANAGE
  )
end
