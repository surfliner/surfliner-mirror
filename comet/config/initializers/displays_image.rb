ActiveSupport::Reloader.to_prepare do
  Hyrax::DisplaysImage.module_eval do
    def latest_file_id
      id
    end
  end
end
