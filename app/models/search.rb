# frozen_string_literal: true

# @abstract Replaces Blacklight's ActiveRecord-based search model with a Redis-based one. Stores the parameters of a
# user's search using a randomly-generated key for an id. These ids are then saved to SearchHistory using the user's
# session id.

class Search
  include RedisSessionStore

  class << self
    def create(**args)
      new(**args).save
    rescue StandardError => e
      Rails.logger.error("Redis is down! Searches will not be kept in session: #{e.message}")
      NullSearch.new
    end

    def find(key)
      value = redis.get(key)
      return if value.nil?

      new(id: key, query_params: value)
    rescue StandardError => e
      Rails.logger.error("Redis is down! Searches will not be kept in session: #{e.message}")
      NullSearch.new
    end
  end

  class NullSearch
    include NullObjectPattern

    def query_params
      {}
    end
  end

  attr_reader :id

  # @param id [String]
  # @param query_params [Hash]
  # @note Unless one is provided, an id will be automatically generated and used as the unique identifier. We don't
  # anticipate storing these ids for longer than a day or two, so it should only be long enough, and have enough
  # entropy, to avoid any collisions during the TTL period in Redis.
  def initialize(id: nil, query_params: nil)
    @query_params = query_params
    @id = generate_id(id)
  end

  # @return [Hash]
  # @note The value is persisted as a json string on write, then parsed back into a hash on read.
  def query_params
    if @query_params.is_a?(Hash)
      @query_params
    else
      JSON.parse(@query_params || '')
    end
  rescue JSON::ParserError
    @query_params
  end

  # @note This is to provide ActiveRecord attribute conformity.
  def [](attribute)
    try(attribute)
  end

  def save
    redis.multi do
      redis.set(id, @query_params.to_json)
      redis.expire(id, ttl)
    end

    self
  end
end
