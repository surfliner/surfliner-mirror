namespace :geniza do
  namespace :sample do
    desc 'Load Blake exhibit and content'
    task blake: [:environment] do
      puts "Loading Blake exhibit"
      create_admin_users
      exhibit = Spotlight::Exhibit.create!(title: "The Anna S. C. Blake Manual Training School")
      exhibit.import(JSON.parse(Rails.root.join('spec', 'fixtures', 'the-anna-s-c-blake-manual-training-school-export.json').read))
      exhibit.save
      exhibit.reindex_later
    end

    desc 'Clean out all content'
    task clean: [:environment] do
      puts "Cleaning out all content"
      Spotlight::Exhibit.all.&:destroy!
      Blacklight.default_index.connection.delete_by_query('*:*', params: { 'softCommit' => true })
    end

    def create_admin_users
      emails = ["bess@curationexperts.com", "mark@curationexperts.com", "jamie@curationexperts.com", "valerie@curationexperts.com"]
      emails.each do |email|
        u = User.new
        u.email = email
        u.password = "password"
        u.save
        Spotlight::Role.create(user: u, resource: Spotlight::Site.instance, role: 'admin')
      end
    end
  end
end
