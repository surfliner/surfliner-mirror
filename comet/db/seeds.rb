# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).

projects = Hyrax.query_service.find_all_of_model(model: Hyrax::AdministrativeSet)

if projects.none?
  puts "\n== Creating default Project (AdministrativeSet)"
  project = Hyrax::AdministrativeSet.new(title: "Default Project")
  project = Hyrax.persister.save(resource: project)
  Hyrax.index_adapter.save(resource: project)

  puts "\n== Creating PermissionTemplate for default AdministrativeSet #{project.id}"
  Hyrax::PermissionTemplate.find_or_create_by!(source_id: project.id.to_s)

  # TODO: feature spec: create a work assigned to workflow, log in as reviewer, approve or take some action
  puts "\n== Loading workflows"
  Rake::Task["hyrax:workflow:load"].execute
end

if Rails.env.development?
  provider = ENV["AUTH_METHOD"]
  puts "\n== Creating development admin users"
  ucsb = User.find_or_create_by(email: "comet-admin@library.ucsb.edu",
    provider: provider)

  ucsd = User.find_or_create_by(email: "comet-admin@library.ucsd.edu",
    provider: provider)

  [ucsb, ucsd].each { |user| puts "\nAdmin user email: #{user.user_key}" }

  puts "\n== Assigning all workflow roles to admin users"
  [ucsb, ucsd].each { |user| user.to_sipity_agent }
  Sipity::WorkflowRole.all.each do |wf_role|
    Sipity::WorkflowResponsibility.find_or_create_by!(agent_id: ucsb.sipity_agent.id, workflow_role_id: wf_role.role_id)
    Sipity::WorkflowResponsibility.find_or_create_by!(agent_id: ucsd.sipity_agent.id, workflow_role_id: wf_role.role_id)
  end
end
