# frozen_string_literal: true

require 'rails_helper'
require 'psulib_blacklight/solr_config'

RSpec.describe PsulibBlacklight::SolrConfig do
  let(:settings_struct) do
    Struct.new(:protocol, :host, :port, :username, :password, :collection)
  end

  let(:solr_settings) do
    settings_struct.new('http', '127.0.0.1', 8983, nil, nil, 'psul_catalog')
  end

  before do
    allow(Settings).to receive(:solr).and_return(solr_settings)
  end

  describe 'Solrcat fallback behavior' do
    it 'uses Settings.solr when Settings.solrcat is blank' do
      allow(Settings).to receive(:solrcat).and_return(
        settings_struct.new('http', '', nil, nil, nil, 'psul_catalog')
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
        settings_struct.new('http', '10.0.0.1', 8984, nil, nil, 'psul_catalog')
      )

      config = described_class.new(namespace: :solrcat)

      expect(config.url).to eq('http://10.0.0.1:8984')
    end
  end
end
