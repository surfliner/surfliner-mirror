# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).

if Rails.env.development?
  provider = ENV["AUTH_METHOD"]
  puts "\n== Creating development admin users"
  ucsb = User.find_or_create_by(email: "comet-admin@library.ucsb.edu",
    provider: provider)

  ucsd = User.find_or_create_by(email: "comet-admin@library.ucsd.edu",
    provider: provider)

  [ucsb, ucsd].each { |user| puts "\nAdmin user email: #{user.user_key}" }

  puts "\n== Creating default Project (AdministrativeSet)"
  project = Hyrax::AdministrativeSet.new(title: "Default Project")
  Hyrax.persister.save(resource: project)
  Hyrax.index_adapter.save(resource: project)
end
