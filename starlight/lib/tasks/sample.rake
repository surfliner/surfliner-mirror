# frozen_string_literal: true

namespace :starlight do
  namespace :sample do
    desc "Load Blake exhibit and content"
    task seed_exhibit: [:environment] do
      puts "Loading Blake exhibit"
      exhibit = Spotlight::Exhibit.create!(title: "The Anna S. C. Blake Manual Training School")
      exhibit.import(JSON.parse(Rails.root.join("spec", "fixtures", "the-anna-s-c-blake-manual-training-school-export.json").read))
      exhibit.save
      exhibit.reindex_later
    end

    desc "Clean out all content"
    task clean: [:environment] do
      puts "Cleaning out all content"
      Spotlight::Exhibit.all.&:destroy!
      Blacklight.default_index.connection.delete_by_query("*:*", params: { "softCommit" => true })
    end

    task seed_admin_user: [:environment] do
      puts "Creating admin user with email: admin@uc.edu"
      u = User.new
      u.email = "admin@uc.edu"
      u.provider = "developer"
      u.save
      Spotlight::Role.create(user: u, resource: Spotlight::Site.instance, role: "admin")
    end
  end
end
