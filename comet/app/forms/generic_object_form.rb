# frozen_string_literal: true

##
# @see https://github.com/samvera/hyrax/wiki/Hyrax-Valkyrie-Usage-Guide#forms
# @see https://github.com/samvera/valkyrie/wiki/ChangeSets-and-Dirty-Tracking
class GenericObjectForm < Hyrax::Forms::ResourceForm(GenericObject)
  include SurflinerSchema::FormFields(:generic_object, loader: ::EnvSchemaLoader.new)

  # Define custom form fields using the Valkyrie::ChangeSet interface
  #
  # property :my_custom_form_field

  # if you want a field in the form, but it doesn't have a directly corresponding
  # model attribute, make it virtual
  #

  # This property is passed by the form when collections are associated with GenericObjects
  # Particularly important, is that in the cases we've identified thusfar, the member_of_collections_ids params is
  # empty, so we rely on this param to populate the former
  property :member_of_collections_attributes, virtual: true,
    populator: :interpret_collections_attributes

  def interpret_collections_attributes(opts)
    member_attributes = input_params.permit(member_of_collections_attributes: {}).to_h
    self.member_of_collection_ids =
      member_attributes["member_of_collections_attributes"].each_with_object(model.member_of_collection_ids.dup) do |(_, attribute), member_ids|
        member_ids << attribute["id"]
      end
  end
end
