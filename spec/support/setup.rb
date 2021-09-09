# frozen_string_literal: true

require 'psulib_blacklight/data_manager'

RSpec.configure do |config|
  config.before :suite do
    PsulibBlacklight::DataManager.clean_database
    PsulibBlacklight::DataManager.clean_redis
    PsulibBlacklight::DataManager.clean_solr
    PsulibBlacklight::DataManager.load_fixtures
  end

  config.after :suite do
    PsulibBlacklight::DataManager.clean_database
  end

  config.before do |example|
    ActionMailer::Base.deliveries.clear
    PsulibBlacklight::DataManager.clean_redis if example.metadata[:redis]
  end
end
