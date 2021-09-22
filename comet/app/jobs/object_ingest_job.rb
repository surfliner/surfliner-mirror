# frozen_string_literal: true

# Create object/complex object and build the relationship for components.
class ObjectIngestJob < CreateWorkJob
  # This will perform ingest for an object and its components with relationship
  # @param user[User] - the depositor
  # @param model[String] - the model name of the object to create
  # @param components[Hash] - the object/components metadata
  # @param log[BatchCreateOperation]
  def perform(user, model, components, log)
    # build object relationship by the order of occurrence of levels: OBJECT, COMPONENT, SUBCOMPONENT
    levels = []
    works = []
    status = []
    log.performing!

    components.each do |attrs|
      levels << attrs.delete(:level).upcase

      work = model.constantize.new
      works << work
      current_ability = Ability.new(user)
      env = Hyrax::Actors::Environment.new(work, current_ability, attrs)
      status << work_actor.create(env)
    end

    return log.fail!("No records ingested!") if components.count.zero?
    return log.success! if status.first
    log.fail!(works.first.errors.full_messages.join("\n"))
  end
end
