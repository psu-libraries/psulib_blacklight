# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'BookCovers', type: :feature do
  describe 'User searches for a book' do
    it 'that happens to have a book cover in the Google Books API', js: true do
      visit '/?utf8=✓&search_field=all_fields&q=Ethical+and+Social+Issues+in+the+Information+Age+AND+9783319707129'
      expect(page).to have_css('img[src*="https://books.google.com/books/content"]')
    end
  end

  describe 'User opens a catalog record page' do
    it 'that happens to have a book cover in the Google Books API', js: true do
      visit '/catalog/22090269'
      expect(page).to have_css('img[src*="https://books.google.com/books/content"]')
    end
  end
end
