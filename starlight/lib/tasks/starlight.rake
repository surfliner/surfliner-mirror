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

  task migrate_iiif_content: [:environment] do
    abort "\nYou must supply APP_URL and OLD_APP_URL environment variables for this task.\n\n" unless ENV["APP_URL"] && ENV["OLD_APP_URL"]

    hostname = ENV["APP_URL"]
    old_hostname = ENV["OLD_APP_URL"]
    # List of table/column pairs to update
    iiif_updates = [{ table: "spotlight_pages", column: "content" },
                    { table: "spotlight_featured_images", column: "iiif_tilesource" },
                    { table: "spotlight_featured_images", column: "iiif_canvas_id" },]

    iiif_updates.each do |u|
      puts "Updating iiif urls for #{u[:table]}:#{u[:column]}.."
      sql = "UPDATE #{u[:table]} SET #{u[:column]} = replace(#{u[:column]}, '#{old_hostname}', '#{hostname}')"
      ActiveRecord::Base.connection.execute(sql)
    end
  end

  task migrate_widget_content: [:environment] do
    unless ENV["ASSET_HOST"]
      abort "\nYou must supply ASSET_HOST environment variables for this task.\n\n"
    end

    TrevorURL.all(/^\/uploads/, "#{ENV["ASSET_HOST"]}/uploads")
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
