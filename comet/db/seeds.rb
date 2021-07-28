# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).

projects = Hyrax.query_service.find_all_of_model(model: Hyrax::AdministrativeSet)

if projects.none?
  puts "\n== Creating default Project (AdministrativeSet)"
  project = Hyrax::AdministrativeSet.new(title: "Default Project")
  project = Hyrax.persister.save(resource: project)
  Hyrax.index_adapter.save(resource: project)
else
  project = projects.find { |p| p.title.include?("Default Project") }
end

puts "\n== Ensuring PermissionTemplate for exists for default AdministrativeSet #{project.id}"
permission_template = Hyrax::PermissionTemplate.find_or_create_by!(source_id: project.id.to_s)

# TODO: feature spec: create a work assigned to workflow, log in as reviewer,
# approve or take some action
puts "\n== Loading workflows"
Rake::Task["hyrax:workflow:load"].execute
puts "\n== Activating surfliner_default workflow"
Sipity::Workflow
  .activate!(permission_template: permission_template, workflow_name: "surfliner_default")

provider = Devise.omniauth_providers.first
puts "\n== Creating #{provider} admin users"

roles = YAML.safe_load(IO.read(Rails.root.join("config", "role_map.yml")))[Rails.env]["admin"]
admins = roles.map do |role|
  User.find_or_create_by!(email: role, provider: provider)
end

admins.each { |user| puts "\nAdmin user email: #{user.user_key}" }

admins.each do |user|
  email = user.user_key
  puts "\n== Assigning all workflow roles to #{email}"
  Sipity::WorkflowRole.all.each do |wf_role|
    Sipity::WorkflowResponsibility.find_or_create_by!(agent_id: user.to_sipity_agent.id, workflow_role_id: wf_role.role_id)
  end

  puts "\n== Assigning permissions to #{email}"
  Hyrax::PermissionTemplateAccess.find_or_create_by!(
    permission_template: permission_template,
    agent_type: "user",
    agent_id: email,
    access: Hyrax::PermissionTemplateAccess::MANAGE
  )
end
