# frozen_string_literal: true

namespace :sidekiq do
  task :restart do
    on roles(:all), in: :groups, limit: 3, wait: 10 do
      sudo :systemctl, "restart", "sidekiq"
    end
  end
end
