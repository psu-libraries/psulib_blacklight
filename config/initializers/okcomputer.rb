# frozen_string_literal: true

OkComputer.mount_at = false

OkComputer::Registry.register(
  'solr',
  OkComputer::SolrCheck.new(Rails.application.config_for(:blacklight)[:url])
)

OkComputer::Registry.register(
  'version',
  HealthChecks::VersionCheck.new
)

OkComputer.make_optional %w(version)
