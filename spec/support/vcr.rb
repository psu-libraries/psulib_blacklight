# frozen_string_literal: true

require 'vcr'

VCR.configure do |c|
  vcr_mode = /rec/i.match?(ENV['VCR_MODE']) ? :all : :once

  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :webmock
  c.configure_rspec_metadata!
  c.allow_http_connections_when_no_cassette = true
  c.ignore_localhost = true
  c.ignore_hosts 'selenium', 'minio', 'solr', Settings.solr.host
  c.debug_logger = File.open('log/vcr.log', 'w')
  c.default_cassette_options = { record: vcr_mode, erb: true, update_content_length_header: true }
end
