# frozen_string_literal: true

namespace :pnpm do
  desc 'Install JavaScript dependencies using pnpm'
  task :install do
    on roles(fetch(:pnpm_roles, :web)) do
      within release_path do
        with fetch(:pnpm_env, {}) do
          execute :pnpm, *Array(fetch(:pnpm_install_command, %w[install --frozen-lockfile]))
        end
      end
    end
  end
end

before 'deploy:updated', 'pnpm:install'
