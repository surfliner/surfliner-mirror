Hyrax::ActiveFedoraDummyModel.class_eval do
  def to_global_id
    URI::GID.build(
      app: GlobalID.app,
      model_name: "Hyrax::ValkyrieGlobalIdProxy",
      model_id: @id
    )
  end
end
