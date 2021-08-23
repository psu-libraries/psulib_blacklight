# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BentoController, type: :controller do
  describe '#index' do
    context 'when an html format request comes in' do
      it 'responds with unsupported media type' do
        get :index, params: { format: :html }

        expect(response).to have_http_status(:unsupported_media_type)
      end
    end

    context 'when it returns json' do
      render_views
      let(:json_response) { JSON.parse(response.body) }

      before do
        get :index, params: { format: :json, utf8: '✓', q: 'green', per_page: '3' }
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'has the expected keys' do
        expect(json_response.keys).to match(['continueSearch', 'meta', 'data'])
      end

      it 'has a continue search link' do
        expect(json_response['continueSearch']).to include('http://test.host/catalog?q=green&utf8=%E2%9C%93')
      end

      it 'has a meta key with metadata containing total count of results' do
        expect(json_response['meta']&.dig('pages', 'total_count')).to be(8)
      end

      it 'has a data key with 3 results' do
        expect(json_response['data'].count).to eq 3
      end
    end
  end
end
