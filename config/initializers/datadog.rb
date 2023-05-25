# frozen_string_literal: true

if Settings.datadog.enabled
  require 'ddtrace'
  Datadog.configure do |c|
    c.tracing.instrument :rails
    c.tracing.instrument :redis
    c.tracing.log_injection = false
    c.env = Settings.datadog.env || Rails.env
  end
end
