module Hyrax
  ##
  # Override Hyrax::Resource to use the base `Hyrax::Name` class for model
  # naming.
  class Resource
    def self._hyrax_default_name_class
      Hyrax::Name
    end
  end
end
