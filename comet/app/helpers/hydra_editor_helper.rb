# frozen_string_literal: true

module HydraEditorHelper
  include RecordsHelperBehavior

  def render_edit_field_partial(field_name, **locals)
    form = locals[:f].object
    schema_definition = form.class.form_definition(field_name.to_sym) if form.try(:schema_derived?)
    if schema_definition
      # The field name has a form definition in the schema.
      render_schema_edit_field_partial_with_action(schema_definition, **locals)
    else
      # No form definition is provided by the schema.
      super(field_name, **locals)
    end
  end

  private

  def render_schema_edit_field_partial_with_action(definition, **locals)
    render "records/edit_fields/schema_field", locals.merge({
      definition: definition,
      key: definition.name.to_sym
    })
  end
end
