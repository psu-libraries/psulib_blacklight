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

  describe 'browse call number redirects' do
    it 'browse_cn redirects to browse UI' do
      current = Settings.matomo_id
      Settings.matomo_id = 7
      get '/?search_field=browse_cn&q=ABC'

      expect(response).to redirect_to '/browse?nearby=ABC'
      Settings.matomo_id = current
    end
  end

  describe 'browse authors redirect' do
    it 'redirects to the author browse path' do
      get '/?search_field=browse_authors&q=Abbott, Deborah'

      expect(response).to redirect_to '/browse/authors?prefix=Abbott%2C+Deborah'
    end
  end

  describe 'browse subjects redirect' do
    it 'redirects to the subject browse path' do
      get '/?search_field=browse_subjects&q=African Americans--'

      expect(response).to redirect_to '/browse/subjects?prefix=African+Americans--'
    end
  end

  describe 'browse titles redirect' do
    it 'redirects to the title browse path' do
      get '/?search_field=browse_titles&q=American'

      expect(response).to redirect_to '/browse/titles?prefix=American'
    end
  end
end
