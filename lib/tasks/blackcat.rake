# frozen_string_literal: true

require 'rsolr'
require 'json'

namespace :blackcat do
  namespace :solr do
    desc 'Posts fixtures to Solr'
    task :index do
      solr = RSolr.connect url: Blacklight.connection_config[:url]
      docs = File.open('spec/fixtures/current_fixtures.json').each_line.map { |l| JSON.parse(l) }
      solr.add docs
      solr.update data: '<commit/>', headers: { 'Content-Type' => 'text/xml' }
    end

    desc 'Delete fixtures from Solr'
    task :deindex do
      solr = RSolr.connect url: Blacklight.connection_config[:url]
      solr.update data: '<delete><query>*:*</query></delete>', headers: { 'Content-Type' => 'text/xml' }
      solr.update data: '<commit/>', headers: { 'Content-Type' => 'text/xml' }
    end
  end

  namespace :traject do
    desc 'Generate fixtures using Traject'
    task :create_fixtures do
      Rake::Task['blackcat:solr:deindex'].invoke
      traject_path = Rails.root.join('..', 'psulib_traject')
      fixtures = Rails.root.join('spec', 'fixtures', 'current_fixtures.json')
      marc_file = Rails.root.join('solr', 'sample_data', 'fixtures.mrc')
      args = "-c lib/traject/psulib_config.rb -w Traject::JsonWriter -o #{fixtures}"
      version = 'RBENV_VERSION=jruby-9.2.0.0'
      Bundler.with_clean_env do
        system("cd #{traject_path} && /bin/bash -l -c '#{version} bundle exec traject #{args} #{marc_file}'")
      end
    end
  end
end
