if Settings.datadog.enabled
    require 'ddtrace'
    Datadog.configure do |c|
        c.use :rails
        c.use :sidekiq, analytics_enabled: true
        c.use :redis
        c.tracer env: Settings.datadog.env || Rails.env
    end
end