# frozen_string_literal: true

require 'solr_wrapper/rake_task'

desc "Run test suite"
task :ci do
  SolrWrapper.default_instance_options = {
      version: '7.4.0',
      port: '8983',
      collection: {
          dir: 'solr/conf/',
          name: 'blacklight-core',
      },
      instance_dir: 'tmp/solr/',
      download_dir: 'tmp/solr_dl'
  }

  Rake::Task['solr:start'].invoke
  # Rake::Task['blackcat:solr:index'].invoke
  Rake::Task['spec'].invoke
  # Rake::Task['blackcat:solr:deindex'].invoke
  Rake::Task['solr:stop'].invoke
end
