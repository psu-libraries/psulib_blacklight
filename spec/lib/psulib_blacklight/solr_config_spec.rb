# frozen_string_literal: true

require 'rails_helper'
require 'psulib_blacklight/solr_config'

RSpec.describe PsulibBlacklight::SolrConfig do
  let(:solr_settings) do
    instance_double(
      'Config::Options',
      protocol: 'http',
      host: '127.0.0.1',
      port: 8983,
      username: nil,
      password: nil,
      collection: 'psul_catalog'
    )
  end

  before do
    allow(Settings).to receive(:solr).and_return(solr_settings)
  end

  describe 'Solrcat fallback behavior' do
    it 'uses Settings.solr when Settings.solrcat is blank' do
      allow(Settings).to receive(:solrcat).and_return(
        instance_double(
          'Config::Options',
          host: '',
          port: nil,
          protocol: 'http',
          collection: 'psul_catalog'
        )
      )
      allow(Rails.logger).to receive(:info)

      config = described_class.new(namespace: :solrcat)

      expect(config.url).to eq('http://127.0.0.1:8983')
      expect(Rails.logger)
        .to have_received(:info)
        .with('Settings.solrcat is missing or empty; falling back to Settings.solr')
    end

    it 'uses Settings.solrcat when it is valid' do
      allow(Settings).to receive(:solrcat).and_return(
        instance_double(
          'Config::Options',
          protocol: 'http',
          host: '10.0.0.1',
          port: 8984,
          username: nil,
          password: nil,
          collection: 'psul_catalog'
        )
      )

      config = described_class.new(namespace: :solrcat)

      expect(config.url).to eq('http://10.0.0.1:8984')
    end
  end
end
