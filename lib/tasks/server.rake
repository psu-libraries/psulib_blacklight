# frozen_string_literal: true

desc 'Run test suite'
task :ci do
  Rake::Task['solr:start'].invoke
  # Rake::Task['blackcat:solr:index'].invoke
  Rake::Task['spec'].invoke
  # Rake::Task['blackcat:solr:deindex'].invoke
  Rake::Task['solr:stop'].invoke
end
