# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'AskALibrarians', type: :feature do
  describe 'side widget slides in as expected', js: true do
    it 'shows up on the homepage' do
      visit root_path
      expect(page).to have_css('button.libchat_online')
    end

    it 'shows up on a catalog item page only once when clicking back button in browser' do
      visit '/catalog/22090269'
      expect(page).to have_css('button.libchat_online', count: 1)
      click_link 'View MARC record'
      expect(page).to have_text('MARC View')
      page.driver.go_back
      expect(page).to have_text('Ethical and Social Issues in the Information Age by Joseph Migga Kizza')
      expect(page).to have_css('button.libchat_online', count: 1)
    end
  end
end
