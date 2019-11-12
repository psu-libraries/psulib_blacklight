# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SitemapController, type: :controller do
  describe 'calculations and responses from solr' do
    let(:sitemap) { SitemapController.new }

    before do
      allow(sitemap).to receive(:max_documents).and_return(7_500_000)
    end

    it 'calculates the number of leaves to divide the index by correctly' do
      expect(sitemap.index.count).to eq 4096
    end

    it 'returns documents in response to the query' do
      sitemap.params = { id: 0 }
      expect(sitemap.show.response[:body]).to include '"numFound":29'
    end
  end

  describe 'xml building' do
    render_views

    it 'renders appropriate XML in the show view' do
      get :show, params: { id: 0 }, format: 'xml'
      expect(response.body).to include '<loc>http://test.host/catalog/125041</loc>'
    end
  end
end
