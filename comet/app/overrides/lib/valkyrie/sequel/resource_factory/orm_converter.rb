# frozen_string_literal: true

Valkyrie::Sequel::ResourceFactory::ORMConverter.class_eval do
  ##
  # Override the resource class resolver for +Valkyrie::Sequel+; this should be
  # upstreamed.
  def resource_klass
    Valkyrie.config.resource_class_resolver.call(internal_resource)
  end
end
