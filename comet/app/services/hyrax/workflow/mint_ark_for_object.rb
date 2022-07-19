# frozen_string_literal: true

module Hyrax
  module Workflow
    ##
    # Mints an ARK for the target object
    # Avoid overriding existing ARK
    module MintARKForObject
      def self.call(target:, **)
        if target.ark.nil? || target.ark.id.blank?
          saved = ARK.mint_for(target.id)
          target.ark = saved.ark
        end
      end
    end
  end
end
