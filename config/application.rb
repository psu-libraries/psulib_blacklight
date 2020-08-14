# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Psulcat
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults '6.0'

    # Should be zeitwerk, but we need to upgrade to Blacklight > 7.9 first. Once we have that we can delete this line.
    config.autoloader = :classic

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # When this is true, the value of the announcement bar is set in `blacklight.announcement.html`
    config.show_announcement = true
  end
end
