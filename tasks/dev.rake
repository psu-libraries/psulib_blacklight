# frozen_string_literal: true

namespace :dev do
  desc 'Clean out everything and reload fixtures'
  task clean: :environment do
    PsulibBlacklight::DataManager.clean_database
    PsulibBlacklight::DataManager.clean_solr
    PsulibBlacklight::SolrManager.new.initialize_collection
    PsulibBlacklight::DataManager.load_fixtures
  end
end
