##
# This class handles authorization for most user initiated actions in Comet.
#
# The scope of the authorizations governed here is this application, usually
# an action mediated by some Controller. For example, a show action might do
# +authorize!(:show, @model)+ as a +before_action+ hook to guarantee
# authorization prior to running controller logic.
#
# When implementing authorizations, take care to respect Comet's ACLs
# (+Hyrax::AccessControlList+). You can think of this class as providing a
# business logic layer and application specific authorization over the top of
# ACLs, which act as a binding, global data layer. For example: don't provide
# +:read+, +:show+, or +:download+ access where an ACL read grant isn't present
# (what about admins? uh oh, Hyrax.).
#
# {Ability} is integrated with controllers via +CanCan::ControllerAdditions+,
# which makes +#current_ability+, +#can?+, +#cannot?+, and +#authorize!+, and
# other controller helpers available to controller instances.
#
# Through Blacklight and Hyrax, we inherit a substantial network of pre-existing
# actions and authorizations. There's an ongoing effort to clean up,
# deduplicate, and document those actions upstream. Please refer to
# +Hyrax::Ability+ for more information.
#
# @note for authorization of workflow actions see
#   +Hyrax::Forms::WorkflowActionForm+.
#
# @note that CanCan treats +:manage+ as a special, superseding action. if you
#   find yourself with unexpected +can?(:action, obj) # => true+ results, it's
#   likely that +current_user+ has +:manage+ access on the relevant object.
#
# @note some of our inherited actions use blacklight's `test_*` infrastructure
#   to check ACL data from the solr indexes. this is a necessary efficency
#   for ActiveFedora applications, but shouldn't be needed for Comet. if you
#   find yourself fighting with index data here, consider reimplementing the
#   relevant checks against `Hyrax::AccessControlList`, which should be more
#   authoritative in real time.
#
# @note CanCan's own "debugging" documentation isn't very helpful for determining
#   which +can+ statement is causing a +true+ result. it's often more helpful to
#   look at +current_ability.rules+ and filter by action and/or subject.
#   e.g. try +current_ability.rules.select { |r| r.actions.include(:read) }+. this
#   can help you see what rules are relevant for a given check. (don't be fooled
#   by +CanCan::Rule#relevant?+, which is hard to use correctly).
#
# @see https://github.com/CanCanCommunity/cancancan/blob/develop/docs/README.md
# @see https://www.rubydoc.info/github/CanCanCommunity/cancancan
# @see https://github.com/CanCanCommunity/cancancan/blob/develop/docs/controller_helpers.md
# @see https://www.rubydoc.info/gems/hyrax/Hyrax/Ability
# @see https://rubydoc.info/gems/hyrax/Hyrax/AccessControlList
class Ability
  include Hydra::Ability
  include Hyrax::Ability

  self.ability_logic += [:everyone_can_create_curation_concerns,
    :object_publication]

  ##
  # @note just assume everyone can deposit works; what are they here for
  #   otherwise? anyway, we imagine that the reasons folks might not have
  #   access will be different from Hyrax's reasons.
  #
  # @return [Boolean]
  def can_create_any_work?
    true
  end

  # for bulkrax
  def can_import_works?
    can_create_any_work?
  end

  def can_export_works?
    can_create_any_work?
  end

  ##
  # Grant publish access to collections that exist (have an id) and allow edit.
  def object_publication
    can :publish, [Hyrax::PcdmCollection, SolrDocument] do |collection|
      # check presence of id first to avoid blacklight errors
      collection.id.present? && can?(:edit, collection)
    end
  end
end
