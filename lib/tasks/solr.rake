# frozen_string_literal: true

require 'psulib_blacklight/solr_manager'
require 'psulib_blacklight/data_manager'

namespace :solr do
  def solr_manager
    @solr_manager ||= PsulibBlacklight::SolrManager.new
  end

  desc 'Remove all data from Solr'
  task clean: :environment do
    PsulibBlacklight::DataManager.clean_solr
  end

  desc 'Creates or updates the collection in solr'
  task initialize_collection: :environment do
    solr_manager.initialize_collection
  end

  desc 'Create a new collection with a configset that is up to date'
  task create_collection: :environment do
    solr_manager.create_collection
  end

  desc 'Creates the alias to the latest collection in solr'
  task create_alias: :environment do
    solr_manager.create_alias
  end

  desc 'Load the test fixtures'
  task load_fixtures: :environment do
    PsulibBlacklight::DataManager.load_fixtures
  end

  desc 'Updates the configuration'
  task update_config: :environment do
    solr_manager.modify_collection
  end

  desc 'Return the latest collection version number'
  task last_incremented_collection: :environment do
    puts solr_manager.last_incremented_collection
  end

  desc 'Delete a collection from solr'
  task :delete_collection, [:collection] => [:environment] do |_task, args|
    raise 'Collection parameter required' unless args['collection']

    solr_manager.delete_collection(args['collection'])
  end
end
