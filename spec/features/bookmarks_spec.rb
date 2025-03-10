# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Bookmarks', :js do
  before do
    # In Rails 6, CSRF protection is turned off by default in test env
    # Turning it on here to test that it doesn't break Bookmarks
    ActionController::Base.allow_forgery_protection = true
  end

  after do
    ActionController::Base.allow_forgery_protection = false
  end

  context 'when the user is not logged in' do
    it 'Shows a link to login' do
      visit '/?utf8=✓&search_field=all_fields&q=Ethical+and+Social+Issues+in+the+Information+Age+AND+9783319707129'
      expect(page).to have_css('.btn', text: 'Bookmark')
      expect(page).to have_css('.btn', text: 'Bookmark All On Page')
      expect(find('a[href="/login?fullpath=%2F%3Futf8%3D%25E2%259C%2593%26search_field%3D' \
                  'all_fields%26q%3DEthical%2Band%2BSocial%2BIssues%2Bin%2Bthe%2BInformat' \
                  'ion%2BAge%2BAND%2B9783319707129"]')).to be_present
      expect(find('a[href="/login?fullpath=%2F%3Futf8%3D%25E2%259C%2593%26search_field%3D' \
                  'all_fields%26q%3DEthical%2Band%2BSocial%2BIssues%2Bin%2Bthe%2BInformat' \
                  'ion%2BAge%2BAND%2B9783319707129&bookmark_doc_id=22090269"]')).to be_present
    end
  end

  context 'when user is logged in' do
    before do
      user = User.create!(email: 'user1234@psu.edu')
      login_as(user, scope: :user)
    end

    it 'Adds, removes, re-adds bookmarks, and views Bookmarks page' do
      visit '/'
      # Test that the 'Bookmark All On Page' button doesn't show on empty search
      expect(page).to have_no_content 'Bookmark All On Page'
      visit '/?search_field=all_fields&q='
      expect(page).to have_content 'Bookmark All On Page'
      first_title = find_all('h3[class^="index_title"]').first.text
      bookmark_all_button = find_by_id('bookmark-all')
      bookmark_buttons = find_all('.toggle-bookmark')
      bookmark_buttons.each do |button|
        expect(button.text).to eq 'Bookmark'
      end
      # Test that the 'Bookmark All On Page' button toggles all bookmark buttons on page
      bookmark_all_button.click
      sleep 0.5
      bookmark_counter = find('span[data-role="bookmark-counter"]')
      bookmark_buttons.each do |button|
        expect(button.text).to eq 'In Bookmarks'
      end
      expect(bookmark_counter.text).to eq '10'
      # Test that the individual Bookmark funtionality still works
      bookmark_buttons.first.click
      sleep 0.5
      expect(bookmark_buttons.first.text).to eq 'Bookmark'
      bookmark_buttons.first.click
      sleep 0.5
      expect(bookmark_buttons.first.text).to eq 'In Bookmarks'
      bookmark_buttons.first.click
      sleep 0.5
      # Test that the 'Bookmark All On Page' button is idempotent
      bookmark_all_button.click
      sleep 0.5
      bookmark_buttons.each do |button|
        expect(button.text).to eq 'In Bookmarks'
      end
      # Test that the Bookmarks page has proper content
      click_on 'Bookmarks'
      expect(page).to have_css :h1, text: 'Bookmarks'
      expect(page).to have_content '1 - 10 of 10'
      expect(page).to have_content first_title
    end
  end
end
