# frozen_string_literal: true

##
# Create a Default Project if one does not already exist.
RSpec.shared_context "with an admin set" do
  before do
    projects = Hyrax.query_service.find_all_of_model(model: Hyrax::AdministrativeSet)
    project = projects.find { |p| p.title.include?("Default Project") }

    if project.blank?
      new_project = Hyrax::AdministrativeSet.new(title: "Default Project")
      new_project = Hyrax.persister.save(resource: new_project)
      Hyrax.index_adapter.save(resource: new_project)
    end
  end
end
