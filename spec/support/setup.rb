# frozen_string_literal: true

require 'psulib_blacklight/data_manager'

RSpec.configure do |config|
  config.before :suite do
    PsulibBlacklight::DataManager.clean_redis
    PsulibBlacklight::DataManager.clean_solr
    PsulibBlacklight::DataManager.load_fixtures
  end

  config.before do |example|
    if example.metadata[:redis]
      PsulibBlacklight::DataManager.clean_redis
    end
  end
end
