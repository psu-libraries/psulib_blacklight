# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Errors' do
  describe 'not found text' do
    before(:all) { get '/Copernicus.txt' }

    it 'has http status 404' do
      expect(response).to have_http_status(:not_found)
    end

    it 'returns text response' do
      expect(response.body).to eq('not found')
    end
  end

  describe 'not found' do
    before (:all) { get '/404' }

    it 'has http status 404' do
      expect(response).to have_http_status(:not_found)
    end

    it 'redirects to customized not_found error page' do
      expect(response.body).to include("The page you were looking for doesn't exist")
    end
  end

  describe 'internal server error' do
    it 'has http status 500 and redirects to customized internal_server_error error page' do
      respond_without_detailed_exceptions do
        allow(RSolr).to receive(:connect).and_raise(Exception)
        get '/'
        expect(response).to have_http_status(:internal_server_error)
        expect(response.body).to include("We're sorry, but something went wrong.")
      end
    end
  end

  describe 'response to Blacklight::Exceptions::RecordNotFound exception' do
    it 'redirects to customized 404 page' do
      get '/catalog/wrongid'
      expect(response).to redirect_to('/404')
      follow_redirect!

      expect(response).to have_http_status(:not_found)
      expect(response.body).to include("The page you were looking for doesn't exist")
    end
  end
end
