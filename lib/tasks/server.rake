# frozen_string_literal: true

require "solr_wrapper" unless Rails.env.production?

desc "Run test suite"
task :ci do
  SolrWrapper.default_instance_options = {
      version: '7.4.0',
      port: '8983'
  }
  @solr_instance = SolrWrapper.default_instance

  Rake::Task['solr:start'].invoke
  Rake::Task['spec'].invoke
end
