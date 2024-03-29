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

  task add_exhibit_admin: [:environment] do
    print 'Exhibit URL slug: '
    exhibit_slug = $stdin.gets.chomp

    print 'User email address: '
    email = $stdin.gets.chomp

    user = User.find_by(email: email)
    exhibit = Spotlight::Exhibit.find_by(slug: exhibit_slug)
    Spotlight::Role.create(user: user, resource: exhibit, role: "admin")
  end

  task migrate_iiif_content: [:environment] do
    unless ENV["APP_URL"] && ENV["OLD_APP_URL"]
      abort "\nYou must supply APP_URL and OLD_APP_URL environment variables for this task.\n\n"
    end

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

    TrevorURL.rewrite_all(/^\/uploads/, "#{ENV["ASSET_HOST"]}/uploads")
  end

  task :reindex_now, [:exhibit_slug] => :environment do |_, args|
    exhibits = if args[:exhibit_slug]
                 Spotlight::Exhibit.where(slug: args[:exhibit_slug])
               else
                 Spotlight::Exhibit.all
               end

    exhibits.find_each do |e|
      puts " == Reindexing #{e.title} =="

      e.resources.each do |resource|
        resource.reindex(touch: false, commit: false)
      end
    end
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
