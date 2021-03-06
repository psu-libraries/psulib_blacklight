# frozen_string_literal: true

require 'rsolr'
require 'json'

namespace :blackcat do
  namespace :solr do
    desc 'Posts fixtures to Solr'
    task index: :environment do
      solr = RSolr.connect url: Blacklight.connection_config[:url]
      docs = File.open('spec/fixtures/current_fixtures.json').each_line.map { |l| JSON.parse(l) }
      solr.add docs
      solr.update data: '<commit/>', headers: { 'Content-Type' => 'text/xml' }
    end

    desc 'Delete fixtures from Solr'
    task deindex: :environment do
      solr = RSolr.connect url: Blacklight.connection_config[:url]
      solr.update data: '<delete><query>*:*</query></delete>', headers: { 'Content-Type' => 'text/xml' }
      solr.update data: '<commit/>', headers: { 'Content-Type' => 'text/xml' }
    end
  end

  namespace :traject do
    desc 'Generate fixtures using Traject'
    task create_fixtures: :environment do
      # Note: updates to the sample_psucat.mrc file are produced by Maryam. We can request a new version of the file
      # with examples that we are seeking and she will produce it and place it on the symphony server.
      traject_path = Rails.root.join('../psulib_traject')
      fixtures = Rails.root.join('spec/fixtures/current_fixtures.json')
      marc_file = Rails.root.join('solr/sample_data/*.mrc')
      args = "-c lib/traject/psulib_config.rb -w Traject::JsonWriter -o #{fixtures}"
      version = 'RBENV_VERSION=jruby-9.2.11.1'
      Bundler.with_clean_env do
        system("cd #{traject_path} && /bin/bash -l -c '#{version} bundle exec traject #{args} #{marc_file}'")
      end
    end
  end
end
