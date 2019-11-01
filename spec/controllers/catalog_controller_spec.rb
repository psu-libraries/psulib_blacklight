# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CatalogController, type: :controller do
  let(:doc_id) { '20049333' }

  describe 'index action' do
    it 'gets the homepage and doesn\'t hit Solr' do
      get :index
      expect(assigns(:response)).to be_nil
    end

    it 'pages too deep' do
      get :index, params: { page: 251 }
      expect(:response).to redirect_to '/404'
    end
  end

  describe 'facet action' do
    it 'facet pages too deep' do
      get :facet, params: { id: 'format', 'facet.page': 51 }

      expect(response).to redirect_to '/404'
    end
  end

  describe 'route check' do
    it 'routes /catalog/:id properly' do
      expect(get: '/catalog/:id').to route_to(controller: 'catalog', action: 'show', id: ':id')
    end

    it 'routes marc_view properly' do
      expect(get: '/catalog/:id/marc_view').to route_to(controller: 'catalog', action: 'librarian_view', id: ':id')
    end
  end
end
