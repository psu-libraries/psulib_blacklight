# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Bookmarks', type: :feature do
  before do
    # In Rails 6, CSRF protection is turned off by default in test env
    # Turning it on here to test that it doesn't break Bookmarks
    ActionController::Base.allow_forgery_protection = true
  end

  after do
    ActionController::Base.allow_forgery_protection = false
  end

  context 'when the user is not logged in' do
    it 'Shows a link to login', js: true do
      visit '/?utf8=✓&search_field=all_fields&q=Ethical+and+Social+Issues+in+the+Information+Age+AND+9783319707129'
      expect(page).to have_css('.btn', text: 'Bookmark')
      expect(page).to have_link(href: /login/)
    end
  end

  context 'when user is logged in' do
    before do
      user = User.create!(email: 'user1234@psu.edu')
      login_as(user, scope: :user)
    end

    context 'when Bookmarking all on page' do
      it 'Adds, removes, re-adds bookmarks, and views Bookmarks page', js: true do
        visit '/'
        # Test that the 'Bookmark All On Page' button doesn't show on empty search
        expect(page).not_to have_content 'Bookmark All On Page'
        visit '/?search_field=all_fields&q='
        expect(page).to have_content 'Bookmark All On Page'
        first_title = find_all('h3[class^="index_title"]').first.text
        bookmark_all_button = find('#bookmark-all')
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
        click_link 'Bookmarks'
        expect(page).to have_css :h1, text: 'Bookmarks'
        expect(page).to have_content '1 - 10 of 10'
        expect(page).to have_content first_title
      end
    end
  end
end
