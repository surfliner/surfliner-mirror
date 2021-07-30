# frozen_string_literal: true

namespace :comet do
  namespace :users do
    desc "Delete all users with a given provider name"
    task :delete_by_provider, [:provider] => [:environment] do |_t, args|
      ::User.where(provider: args[:provider].to_s).destroy_all
    end
  end
end
