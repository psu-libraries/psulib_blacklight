# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CatalogController, type: :controller do
  let(:doc_id) { '20049333' }

  describe 'index action' do
    it 'gets search results from the solr index' do
      get :index
      expect(response).to be_success
    end
  end

  describe 'route check' do
    it 'routes /catalog/:id properly' do
      expect(get: '/catalog/:id').to route_to(controller: 'catalog', action: 'show', id: ':id')
    end

    it 'routes librarian_view properly' do
      expect(get: '/catalog/:id/librarian_view').to route_to(controller: 'catalog', action: 'librarian_view', id: ':id')
    end
  end
end
