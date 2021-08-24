# frozen_string_literal: true

# Do not let rack-mini-profiler disable caching
Rack::MiniProfiler.config.disable_caching = false

# Store data in Redis, which can be shared accross multiple containers
Rack::MiniProfiler.config.storage_options = { url: Settings.redis.sessions.uri }
Rack::MiniProfiler.config.storage = Rack::MiniProfiler::RedisStore
