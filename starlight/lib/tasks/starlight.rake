# frozen_string_literal: true

namespace :starlight do
  task seed_admin_user: [:environment] do
    provider = ENV["AUTH_METHOD"]
    email = "admin@localhost"
    password = "testing"

    puts "Creating admin #{provider} user with email: #{email} (password: '#{password}')"
    u = User.find_or_create_by(email: email) do |user|
      user.provider = provider
      user.password = password
    end
    Spotlight::Role.create(user: u, resource: Spotlight::Site.instance, role: "admin")
  end

  task reindex_all: [:environment] do
    puts "Reindexing all exhibits"
    Spotlight::Exhibit.all.each(&:reindex_later)
  end

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
  end
end
