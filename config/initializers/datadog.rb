# frozen_string_literal: true

if Settings.datadog.enabled
  require 'ddtrace'
  Datadog.configure do |c|
    c.use :rails
    c.use :redis
    c.tracer env: Settings.datadog.env || Rails.env
  end
end
