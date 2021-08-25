# frozen_string_literal: true

##
# A custom build strategy for saving Valkyrie/data mapper objects.
class ValkyrieCreate
  def initialize
    @association_strategy = FactoryBot.strategy_by_name(:build).new
  end

  delegate :association, to: :@association_strategy

  def result(evaluation)
    instance = evaluation.object

    evaluation.notify(:after_build, instance)

    adapter = Valkyrie::MetadataAdapter.find(Lark.config.index_adapter)
    persister = adapter.persister

    evaluation.notify(:before_create, instance)
    evaluation.notify(:before_valkyrie_create, instance)
    instance = persister.save(resource: instance)
    evaluation.notify(:after_create, instance)
    evaluation.notify(:after_valkyrie_create, instance)

    instance
  end
end
