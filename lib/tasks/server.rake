# frozen_string_literal: true

desc 'Run test suite'
task ci: :environment do
  Rake::Task['blackcat:solr:index'].invoke
  Rake::Task['spec'].invoke
  Rake::Task['blackcat:solr:deindex'].invoke
end
