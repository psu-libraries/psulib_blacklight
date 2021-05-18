# frozen_string_literal: true

class CatalogCleaner
  def self.clean_redis
    Redis.new(url: Settings.redis.sessions.uri).flushdb
  end
end

RSpec.configure do |config|
  config.before :suite do
    CatalogCleaner.clean_redis
  end

  config.before do |example|
    if example.metadata[:redis]
      CatalogCleaner.clean_redis
    end
  end
end
