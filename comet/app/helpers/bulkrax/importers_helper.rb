module Bulkrax
  module ImportersHelper
    include WithAdminSetSelection

    def available_admin_sets
      super.select_options
    end
  end
end
