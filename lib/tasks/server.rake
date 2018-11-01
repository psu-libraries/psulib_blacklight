# frozen_string_literal: true

desc 'Run test suite'
task :ci do
  within_test_app do
    solr.with_collection do
      system "RAILS_ENV=test rake blacklight:index:seed"
    end
  end


  Rake::Task['solr:start'].invoke
  # Rake::Task['blackcat:solr:index'].invoke
  Rake::Task['spec'].invoke
  # Rake::Task['blackcat:solr:deindex'].invoke
  Rake::Task['solr:stop'].invoke
end
