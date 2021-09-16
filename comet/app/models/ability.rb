class Ability
  include Hydra::Ability
  include Hyrax::Ability

  self.ability_logic += [:everyone_can_create_curation_concerns]

  # Define any customized permissions here.
  def custom_permissions
    can :read, Hyrax::PcdmCollection do |collection|
      test_read(collection.id)
    end
  end

  ##
  # @note just assume everyone can deposit works; what are they here for
  #   otherwise? anyway, we imagine that the reasons folks might not have
  #   access will be different from Hyrax's reasons.
  #
  # @return [Boolean]
  def can_create_any_work?
    true
  end
end
