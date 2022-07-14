# frozen_string_literal: true

module Hyrax
  module Workflow
    ##
    # Mints an ARK for the target object
    module MintARKForObject
      def self.call(target:, **)
        return false unless (id = target.try(:id))

        ARK.mint_for(id)
      end
    end
  end
end
