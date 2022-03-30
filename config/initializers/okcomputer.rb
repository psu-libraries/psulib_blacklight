# frozen_string_literal: true

OkComputer.mount_at = false

OkComputer::Registry.register(
  'solr',
  OkComputer::SolrCheck.new(Rails.application.config_for(:blacklight)[:url])
)

OkComputer::Registry.register(
  'migrations',
  OkComputer::ActiveRecordMigrationsCheck.new
)

OkComputer::Registry.register(
  'version',
  OkComputer::AppVersionCheck.new(env: 'APP_VERSION')
)

OkComputer.make_optional %w(version)
