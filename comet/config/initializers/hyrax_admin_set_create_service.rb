ActiveSupport::Reloader.to_prepare do
  Hyrax::AdminSetCreateService.class_eval do
    class << self
      ##
      # Never create admin sets passively at runtime; we createthe default set with a seed.
      def find_or_create_default_admin_set
        find_default_admin_set ||
          raise("Failed to find a default admin set. " \
                "Comet declines to create them at runtime. " \
                "Why didn't one get created by the db seeds?")
      end

      ##
      # Find a project named "Default Project" and just keep it in memory.
      # If there's not one, just use whatever project pops up first.
      def find_default_admin_set
        projects = Hyrax.query_service.find_all_of_model(model: Hyrax::AdministrativeSet)
        projects.find { |p| p.title.include?("Default Project") } || projects.first
      end
    end
  end
end
