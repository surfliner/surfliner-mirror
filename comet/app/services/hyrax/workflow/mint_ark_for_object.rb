# frozen_string_literal: true

module Hyrax
  module Workflow
    ##
    # Mints an ARK for the target object
    module MintARKForObject
      def self.call(target:, **)
        return false unless (id = target.try(:id))

        saved = ARK.mint_for(id)
        target.ark = saved.ark
      end
    end
  end
end
