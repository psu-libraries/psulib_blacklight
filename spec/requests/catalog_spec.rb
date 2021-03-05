# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Catalog', type: :request do
  describe 'id in the url ending with a punctuation' do
    it 'redirects to the record after cleaning the punctuation' do
      get '/catalog/22090269.'
      expect(response).to redirect_to '/catalog/22090269'
      follow_redirect!

      expect(response).to have_http_status(:success)
    end
  end
end
