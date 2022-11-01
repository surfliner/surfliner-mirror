# frozen_string_literal: true

# Override the default Hyrax +curation_concerns+ configuration method, which
# just does an (unsafe) +constantize+, to instead use the Valkyrie resource
# class resolver (which we override to support M3 classes).
Hyrax::Configuration.class_eval do
  def curation_concerns
    registered_curation_concern_types.map(
      &Valkyrie.config.resource_class_resolver
    )
  end
end
