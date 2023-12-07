# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Previous Next Toggle', type: :feature do
  describe 'Previous next links toggle', js: true do
    it 'does not display stale previous and next links for direct item views' do
      visit root_path
      fill_in 'q', with: ''
      click_button 'search'
      click_on 'An American marriage / a novel by Tayari Jones'
      expect(page.text).to match(/← Previous | [0-9]+ of [0-9]+ | Next →/)

      # Go to the number 6 result separately
      visit '/catalog/24053587'
      expect(page).not_to have_selector '.page-links'
      expect(page.text).not_to match(/← Previous | [0-9]+ of [0-9]+ | Next →/)
    end
  end
end
