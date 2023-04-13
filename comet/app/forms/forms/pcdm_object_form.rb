# frozen_string_literal: true

module Forms
  ##
  # Dynamically creates a new +PcdmObjectForm+ class for the provided
  # (+Resource+) model class.
  #
  # The class created through this method is not intended to be used for
  # collections or file·sets, which ought to have their own (hardcoded) forms.
  #
  # Compare +Hyrax::Forms::ResourceForm+.
  def self.PcdmObjectForm(model_class)
    Class.new(::Forms::PcdmObjectForm) do
      self.model_class = model_class

      include Hyrax::FormFields(:core_metadata)
      include SurflinerSchema::FormFields(model_class.availability, loader: ::SchemaLoader.new)

      def self.inspect
        return "Forms::PcdmObjectForm(#{model_class})" if name.blank?
        super
      end
    end
  end

  ##
  # @see https://github.com/samvera/valkyrie/wiki/ChangeSets-and-Dirty-Tracking
  class PcdmObjectForm < Hyrax::Forms::PcdmObjectForm
    # Define custom form fields using the Valkyrie::ChangeSet interface
    #
    # property :my_custom_form_field

    # if you want a field in the form, but it doesn't have a directly
    # corresponding model attribute, make it virtual

    # This property is passed by the form when collections are associated with
    # GenericObjects. Particularly important, is that in the cases we’ve
    # identified thus far, the member_of_collections_ids params is empty, so we
    # rely on this param to populate the former
    property :member_of_collections_attributes, virtual: true,
      populator: :interpret_collections_attributes

    property :embargo, form: EmbargoForm, populator: :embargo_populator
    property :lease, form: LeaseForm, populator: :lease_populator

    property :visibility, default: Hyrax::VisibilityIntention::PRIVATE, populator: :visibility_populator

    def primary_terms
      _form_field_definitions.select { |key, form_options|
        schema_definition = self.class.form_definition(key.to_sym)
        if schema_definition
          # Use the schema definition if possible.
          schema_definition.primary?
        else
          # Hyrax‐defined primary terms have a :primary form option.
          form_options[:primary]
        end
      }.keys.map(&:to_sym)
    end

    def secondary_terms
      _form_field_definitions.select { |key, form_options|
        schema_definition = self.class.form_definition(key.to_sym)
        if schema_definition
          # Display all schema‐defined nonprimary terms.
          !schema_definition.primary?
        else
          # Hyrax‐defined secondary terms have a :display form option but a
          # falsey :primary.
          form_options[:display] && !form_options[:primary]
        end
      }.keys.map(&:to_sym)
    end

    def interpret_collections_attributes(opts)
      adds = []
      deletes = []
      member_attributes = input_params.permit(member_of_collections_attributes: {}).to_h
      tmp_member_ids = member_attributes["member_of_collections_attributes"].each_with_object(model.member_of_collection_ids.dup) do |(_, attribute), member_ids|
        if attribute["_destroy"] == "true"
          deletes << Valkyrie::ID.new(attribute["id"])
        else
          adds << Valkyrie::ID.new(attribute["id"])
          member_ids << attribute["id"]
        end
      end
      self.member_of_collection_ids = ((tmp_member_ids + adds) - deletes).uniq
    end

    def embargo_populator(fragment:, **)
      self.embargo = Hyrax::EmbargoManager.embargo_for(resource: model)
    end

    def lease_populator(fragment:, **)
      self.lease = Hyrax::LeaseManager.lease_for(resource: model)
    end

    def visibility_populator(fragment:, doc:, **)
      case fragment
      when "embargo"
        self.visibility = doc["visibility_during_embargo"]

        doc["embargo"] = doc.slice("visibility_after_embargo",
          "visibility_during_embargo",
          "embargo_release_date")
      when "lease"
        self.visibility = doc["visibility_during_lease"]
        doc["lease"] = doc.slice("visibility_after_lease",
          "visibility_during_lease",
          "lease_expiration_date")
      else
        self.visibility = fragment
      end
    end

    ##
    # Dynamically returns a new PcdmObjectForm subclass for the provided
    # Resource.
    def self.for(resource:)
      ::Forms::PcdmObjectForm(resource.class).new(resource)
    end
  end
end
