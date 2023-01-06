# frozen_string_literal: true

##
# A module which overrides the +for+ method, intended to be *prepended* to the
# +Hyrax::Forms::ResourceForm+ singleton class.
#
# Prepending allows the use of +super+ to get the default Hyrax implementation.
module ResourceFormForOverride
  def for(resource)
    constantized_class = "#{resource.class}Form".safe_constantize
    if constantized_class
      # A form class for the provided resource has been defined as a const.
      constantized_class.new(resource)
    elsif resource.is_a?(::Resource)
      # The provided resource is a dynamically‐generated M3 resource.
      ::Forms::PcdmObjectForm.for(resource: resource)
    else
      # The provided resource is not a dynamically‐generated M3 resource.
      super(resource)
    end
  end
end

Hyrax::Forms::ResourceForm.singleton_class.class_eval do
  prepend ResourceFormForOverride
end

##
# A module which provides a +schema_derived?+ method to Hyrax resource forms,
# to identify whether they support +SurflinerSchema::FormFields+ methods or not.
module ResourceFormSchemaDerivedOverride
  def schema_derived?
    self.class.included_modules.any? { |m| m.is_a? SurflinerSchema::FormFields }
  end
end

Hyrax::Forms::ResourceForm.class_eval do
  include ResourceFormSchemaDerivedOverride
end
