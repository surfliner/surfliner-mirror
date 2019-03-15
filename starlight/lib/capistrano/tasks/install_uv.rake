# frozen_string_literal: true

task :install_uv do
  on roles(:all) do
    within "#{deploy_to}/current" do
      execute(:mv, "node_modules/universalviewer public")
    end
  end
end
