# frozen_string_literal: true

namespace :comet do
  namespace :projects do
    desc "Delete empty Projects from the repository"
    task delete_empty: :environment do
      projects = Hyrax.query_service.find_all_of_model(model: Hyrax::AdministrativeSet)
      Hyrax.logger.info("Cleaning up empty Projects; there are #{projects.count} in total.")

      projects.each do |project|
        Hyrax::Transactions::Container["admin_set_resource.destroy"].call(project).value_or do |failure|
          if failure[:admin_set_has_members]
            Hyrax.logger.info("Not deleting Project: #{project.id}")
            next
          end
          Hyrax.logger.error(failure)
        end
      end
    end
  end
end
