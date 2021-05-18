# frozen_string_literal: true

# @abstract Stores a set of Search ids in Redis using the user's session id. This is used in conjunction with
# SearchContext to store and retrieve the user's previous searches.

class SearchHistory
  include RedisSessionStore

  class << self
    # @param session_id [String]
    def find_or_initialize(session_id)
      new(id: session_id).reload
    rescue StandardError => e
      Rails.logger.error("Redis is down! Searches will not be kept in session: #{e.message}")
      NullHistory.new
    end
  end

  class NullHistory
    include NullObjectPattern
    def searches
      []
    end
  end

  attr_reader :id

  # @param id [String]
  def initialize(id: id)
    @id = generate_id(id)
  end

  # @return [Array<Search>]
  def searches
    search_ids
      .map { |search_id| Search.find(search_id) }
      .compact
  end

  # @return [Array<String>]
  def search_ids
    @search_ids ||= redis.lrange(id, 0, -1)
  end

  # @param search [Search, String]
  # @return self
  def add(search)
    key = search.try(:id) || search

    redis.multi do
      redis.lpush(id, key)
      redis.ltrim(id, 0, (limit - 1))
      redis.expire(id, ttl)
    end

    reload
  end

  # @return self
  def reload
    @search_ids = redis.lrange(id, 0, -1)
    self
  end

  private

    def limit
      @limit ||= Settings.search_history_window
    end
end
