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

    it 'Adds, removes, re-adds, and views a bookmarked record', js: true do
      visit '/?utf8=✓&search_field=all_fields&q=Ethical+and+Social+Issues+in+the+Information+Age+AND+9783319707129'
      bookmark_buttons = find_all('.toggle-bookmark')
      bookmark_buttons.first.click
      sleep 1
      expect(page).to have_content 'In Bookmarks'
      bookmark_buttons.first.click
      sleep 1
      expect(page).not_to have_content 'In Bookmarks'
      bookmark_buttons.first.click
      sleep 1
      click_link 'Bookmarks'
      expect(page).to have_css :h1, text: 'Bookmarks'
      expect(page).to have_content '1 entry found'
      expect(page).to have_content 'Ethical and Social Issues in the Information Age'
    end
  end
end
