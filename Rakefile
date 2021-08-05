# frozen_string_literal: true

# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

unless Rails.env.production?
  Rails.root.join('tasks').children.map { |file| load(file) }

  desc 'Run continuous integration build'
  task ci: :environment do
    Rake::Task['blackcat:solr:index'].invoke
    Rake::Task['spec'].invoke
    Rake::Task['blackcat:solr:deindex'].invoke
  end

  task default: :ci
end

Rails.application.load_tasks
