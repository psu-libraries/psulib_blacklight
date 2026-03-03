# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'BookCovers' do
  before do
    stub_request(:any, /hathitrust/).to_return(status: 200, body: '{}', headers: {})
    user = User.create!(email: 'user1234@psu.edu')
    login_as(user, scope: :user)
  end

  describe 'User searches for a book' do
    it 'that happens to have a book cover in the Google Books API', :js do
      visit '/?utf8=✓&search_field=all_fields&q=Ethical+and+Social+Issues+in+the+Information+Age+AND+9783319707129'
      expect(page).to have_css('img[src*="https://books.google.com/books/content"]')
    end
  end

  describe 'User opens a catalog record page' do
    it 'that happens to have a book cover in the Google Books API', :js do
      visit '/catalog/22090269'
      expect(page).to have_css('img[src*="https://books.google.com/books/content"]')
    end
  end
end
