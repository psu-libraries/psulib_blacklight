# frozen_string_literal: true

module RedisSessionStore
  extend ActiveSupport::Concern

  class_methods do
    def redis
      @redis ||= Redis.new(url: Settings.redis.sessions.uri)
    end
  end

  def redis
    @redis ||= self.class.redis
  end

  private

    def ttl
      @ttl ||= Settings.redis.sessions.ttl
    end

    # @param id [String,Rack::Session::SessionId]
    # @return [String] prefixed Redis key
    def generate_id(id)
      prefix = self.class.to_s.parameterize
      id ||= SecureRandom.hex(16)
      return id if id.to_s.starts_with?(prefix)

      "#{prefix}:#{id}"
    end
end
