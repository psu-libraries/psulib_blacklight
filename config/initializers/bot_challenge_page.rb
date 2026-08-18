# frozen_string_literal: true

BotChallengePage.configure do |config|
  enabled =
    !Rails.env.test? &&
    ActiveModel::Type::Boolean.new.cast(ENV.fetch('CF_CHALLENGE_ENABLED', 'true'))

  config.enabled = enabled

  # Get from CloudFlare Turnstile: https://www.cloudflare.com/application-services/products/turnstile/
  # Some testing keys are also available: https://developers.cloudflare.com/turnstile/troubleshooting/testing/
  #
  # Always pass testing sitekey: "1x00000000000000000000AA"
  config.cf_turnstile_sitekey = ENV.fetch(
    'CF_SITE_KEY',
    '1x00000000000000000000AA'
  )
  # Always pass testing secret_key: "1x0000000000000000000000000000000AA"
  config.cf_turnstile_secret_key = ENV.fetch(
    'CF_SECRET_KEY',
    '1x0000000000000000000000000000000AA'
  )

  # For rate-limiting, we need a rails cache store that keeps state, by default
  # will use `config.action_controller.cache_store` or Rails.cache, but if you'd
  # like to use a separate store database, eg. :
  # config.store = ActiveSupport::Cache::RedisCacheStore.new(url: "...")

  # Filter to omit requests from bot challenge control, executed in controller instance context
  #
  config.skip_when = ->(_config) {
    # Does not challenge logged-in, non-guest users
    return true if current_user.present? && !current_user.guest?

    # Does not challenge "Good Bots" – we have another layer of filters so Header containing "Bot" should be legit
    !!(request.headers['User-Agent'] =~ /bot|nagios-plugins/i)
  }

  # Hook after a bot challenge is presented, for logging or other
  # config.after_blocked = ->(bot_challenge_controller) {
  # }

  # How long will a challenge success exempt a session from further challenges?
  config.session_passed_good_for = 15.minutes

  # Functions like to Rails rate_limit `by` parameter, as a configured default.
  # A discriminator or identifier in which a client's requests will be bucketted
  # by rate limit. Normally this gem buckets by IP address subnets. Switching
  # to individual IPs would be much more generous:
  # config.default_limit_by = ->(config) {
  #   request.remote_ip
  #  }

  # When a "pass" cookie is saved, a fingerprint value is stored with it,
  # and subsequent uses of the pass need to have a request that matches
  # fingerprint. By default we insist on IP subnet match, and same user-agent
  # and other headers. But can be customized.
  # config.session_valid_fingerprint = ->(request) {
  #    # whatever
  # }
end
