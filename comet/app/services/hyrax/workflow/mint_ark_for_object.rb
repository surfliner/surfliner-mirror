# frozen_string_literal: true

module Hyrax
  module Workflow
    ##
    # Mints an ARK for the target object
    # Avoid overriding existing ARK
    module MintARKForObject
      def self.call(target:, **)
        saved = ARK.mint_for(target.id)
        target.ark = saved.ark
      rescue ARK::ARKExistingError
        Hyrax.logger.warn("ARK #{target.ark} existing for object #{target.id}.")
      end
    end
  end
end
