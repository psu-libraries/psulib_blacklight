# frozen_string_literal: true

# Do not let rack-mini-profiler disable caching
Rack::MiniProfiler.config.disable_caching = false
