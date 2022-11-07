# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Ask a librarian', type: :feature do
  describe 'side tab widget', js: true do
    before do
      stub_request(:any, /hathitrust/).to_return(status: 200, body: '{}', headers: {})
    end

    it 'shows up on the homepage' do
      visit root_path
      expect(page).to have_css('button[class^="libchat"]')
    end

    it 'shows up on a catalog item page only once after going to MARC View and back' do
      visit '/catalog/22090269'
      click_link 'View MARC record'
      page.assert_selector('h1', text: 'MARC View', wait: 10)
      page.driver.go_back
      page.assert_selector('h1',
                           text: 'Ethical and Social Issues in the Information Age [electronic resource] / by Joseph ' \
                                 'Migga Kizza',
                           wait: 10)
      expect(page).to have_css('button[class^="libchat"]', count: 1)
    end

    it 'shows on the bookmarks page' do
      visit '/bookmarks'
      expect(page).to have_css('button[class^="libchat"]', count: 1)
    end
  end
end
