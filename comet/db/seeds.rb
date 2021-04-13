# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).

if Rails.env.development?
  puts "\n== Creating development admin users"
  ucsb = User.where(email: "comet-admin@library.ucsb.edu").first_or_create do |f|
    f.password = "admin_password"
  end

  ucsd = User.where(email: "comet-admin@library.ucsd.edu").first_or_create do |f|
    f.password = "admin_password"
  end

  [ucsb, ucsd].each { |user| puts "\nAdmin user: #{user.user_key}:admin_password" }

  puts "\n== Creating default Project (AdministrativeSet)"
  project = Hyrax::AdministrativeSet.new(title: "Default Project")
  Hyrax.persister.save(resource: project)
  Hyrax.index_adapter.save(resource: project)
end
