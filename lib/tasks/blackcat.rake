# frozen_string_literal: true

require 'rsolr'
require 'json'

namespace :blackcat do
  namespace :solr do
    desc 'Posts fixtures to Solr'
    task :index do
      solr = RSolr.connect url: Blacklight.connection_config[:url]
      docs = JSON.parse(File.read('spec/fixtures/current_fixtures.json'))
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
end
