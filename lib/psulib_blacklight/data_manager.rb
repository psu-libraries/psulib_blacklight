# frozen_string_literal: true

module PsulibBlacklight
  class DataManager
    def self.clean_redis
      Redis.new(url: Settings.redis.sessions.uri).flushdb
    end

    def self.clean_solr
      Blacklight.default_index.connection.delete_by_query('*:*')
      Blacklight.default_index.connection.commit
    end

    # @note Loads fixtures for our development and testing environments
    def self.load_fixtures
      docs = File.open('spec/fixtures/current_fixtures.json').each_line.map { |l| JSON.parse(l) }
      Blacklight.default_index.connection.add(docs)
      Blacklight.default_index.connection.commit
    end
  end
end
