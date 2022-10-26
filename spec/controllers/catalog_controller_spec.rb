# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CatalogController, type: :controller do
  describe 'index action' do
    it 'gets the homepage and renders only the homepage facets' do
      get :index
      configured_home_page_facets = %w[access_facet format campus_facet media_type_facet classification_pivot_field]
      expect(assigns(:blacklight_config)[:facet_fields].keys).to eq(configured_home_page_facets)
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
      expect(get: '/catalog/id').to route_to(controller: 'catalog', action: 'show', id: 'id')
    end

    it 'routes marc_view properly' do
      expect(get: '/catalog/id/marc_view').to route_to(controller: 'catalog', action: 'librarian_view', id: 'id')
    end
  end

  context 'when there is an invalid search', api: false do
    let(:service) { instance_double(Blacklight::SearchService) }
    let(:fake_error) { Blacklight::Exceptions::InvalidRequest.new }

    before do
      allow(controller).to receive(:search_service).and_return(service)
      allow(service).to receive(:search_results) { |*_args| raise fake_error }
      allow(Rails.env).to receive_messages(test?: false)
    end

    it 'redirects the user to the root url for a bad search' do
      expect(controller.logger).to receive(:error).with(fake_error)
      get :index, params: { q: '+' }
      expect(response.redirect_url).to eq root_url
      expect(request.flash[:notice]).to eq 'Sorry, our search index experienced a problem. Please try again in a moment. If this error persists, please [report the issue](https://libraries.psu.edu/website-feedback) to Libraries Strategic Technology.'
      expect(response).not_to be_successful
      expect(response).to have_http_status :found
    end

    it 'returns status 500 if the catalog path is raising an exception' do
      allow(controller).to receive(:flash).and_return(notice: I18n.t('blacklight.search.errors.request_error'))
      expect { get :index, params: { q: '+' } }.to raise_error Blacklight::Exceptions::InvalidRequest
    end
  end
end
