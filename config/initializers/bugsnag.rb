# frozen_string_literal: true

Bugsnag.configure do |config|
  config.app_version = ENV.fetch('APP_VERSION', nil)
  config.release_stage = ENV.fetch('BUGSNAG_RELEASE_STAGE', 'development')

  config.add_on_error(proc do |event|
    path = event.request&.dig(:path)

    false if path&.start_with?('/health')
  end)
end
