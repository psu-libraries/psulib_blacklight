# frozen_string_literal: true

namespace :yarn do
  desc 'Install all JavaScript dependencies as specified via Yarn'
  task :install do
    task 'yarn:install' => []
    Rake::Task['yarn:install'].clear
    # Install only production deps when for not usual envs.
    valid_node_envs = %w[test development production]
    node_env = ENV.fetch('NODE_ENV') do
      rails_env = ENV['RAILS_ENV']
      valid_node_envs.include?(rails_env) ? rails_env : 'production'
    end
    system({ 'NODE_ENV' => node_env }, './bin/yarn install --frozen-lockfile --no-progress')
  end
end
