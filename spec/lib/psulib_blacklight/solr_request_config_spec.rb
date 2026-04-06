# frozen_string_literal: true

require 'rails_helper'
require 'psulib_blacklight/solr_request_config'

RSpec.describe PsulibBlacklight::SolrRequestConfig do
  let(:request) { ActionDispatch::TestRequest.create }
  let(:url) { 'http://solr.example.com:8983/solr/psul_catalog' }
  let(:solr_config) { instance_double(PsulibBlacklight::SolrConfig, query_url: url) }

  before do
    allow(PsulibBlacklight::SolrConfig).to receive(:new).and_return(solr_config)
  end

  describe '#url' do
    context 'when the request is internal' do
      it 'creates a solrcat config for private network requests' do
        request.headers['X-Forwarded-For'] = '10.0.0.1'

        expect(PsulibBlacklight::SolrConfig)
          .to receive(:new)
          .with(namespace: :solrcat, overrides: {})
          .and_return(solr_config)

        described_class.new(request).url
      end
    end

    context 'when the request is external' do
      it 'creates a solr config for public network requests' do
        request.headers['X-Forwarded-For'] = '203.0.113.1'

        expect(PsulibBlacklight::SolrConfig)
          .to receive(:new)
          .with(namespace: :solr, overrides: {})
          .and_return(solr_config)

        described_class.new(request).url
      end
    end

    context 'when the request is internal and solrcat headers are present' do
      it 'creates a solrcat config and passes header overrides' do
        request.headers['X-Forwarded-For'] = '10.0.0.1'
        request.headers['X-SETTINGS__SOLRCAT__HOST'] = 'solrcat.example.com'
        request.headers['X-SETTINGS__SOLRCAT__PORT'] = '8984'

        expect(PsulibBlacklight::SolrConfig)
          .to receive(:new)
          .with(namespace: :solrcat, overrides: { host: 'solrcat.example.com', port: '8984' })
          .and_return(solr_config)

        described_class.new(request).url
      end
    end

    context 'when solr override headers are present' do
      it 'passes header values as overrides' do
        request.headers['X-SETTINGS__SOLR__HOST'] = 'solr.example.com'
        request.headers['X-SETTINGS__SOLR__PORT'] = '8983'

        expect(PsulibBlacklight::SolrConfig)
          .to receive(:new)
          .with(namespace: :solr, overrides: { host: 'solr.example.com', port: '8983' })
          .and_return(solr_config)

        described_class.new(request).url
      end
    end
  end
end
