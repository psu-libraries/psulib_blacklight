# frozen_string_literal: true

require 'psulib_blacklight/solr_manager'
require 'psulib_blacklight/data_manager'

namespace :solr do
  def solr_manager
    @solr_manager ||= PsulibBlacklight::SolrManager.new
  end

  task clean: :environment do
    PsulibBlacklight::DataManager.clean_solr
  end

  task initialize_collection: :environment do
    solr_manager.initialize_collection
  end

  # create a new collection with a configset that is up to date.
  task create_collection: :environment do
    solr_manager.create_collection
  end

  task create_alias: :environment do
    solr_manager.create_alias
  end

  task load_fixtures: :environment do
    PsulibBlacklight::DataManager.load_fixtures
  end

  task update_config: :environment do
    solr_manager.modify_collection
  end

  task last_incremented_collection: :environment do
    puts solr_manager.last_incremented_collection
  end
end
