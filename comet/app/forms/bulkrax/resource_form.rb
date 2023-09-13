module Bulkrax
  def self.ResourceForm(model_class)
    # parent_class = Hyrax::ResourceForm(work_class) # should just be this; fix upstream
    parent_class = "#{model_class.name}Form".safe_constantize
    parent_class ||= "Hyrax::Forms::#{model_class.name}Form".safe_constantize
    parent_class ||= if model_class < ::Resource
      ::Forms::PcdmObjectForm # rubocop:disable Lint/Void need to touch this to force load in some envs :(
      ::Forms::PcdmObjectForm(model_class)
    else
      Hyrax::Forms::ResourceForm(model_class)
    end

    Class.new(parent_class) do
      include Bulkrax::ResourceForm

      ##
      # @return [String]
      def self.inspect
        return "Bulkrax::Forms::ResourceForm(#{model_class})" if name.blank?
        super
      end
    end
  end

  module ResourceForm
    def self.for(resource)
      Bulkrax::ResourceForm(resource.class).new(resource)
    end

    def self.included(base)
      # add custom validations like
      # base.validates :title, presence: true
    end
  end
end
