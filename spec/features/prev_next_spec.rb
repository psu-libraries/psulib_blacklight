# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Previous Next Toggle' do
  describe 'Previous next links toggle', :js do
    it 'does not display stale previous and next links for direct item views' do
      visit root_path
      fill_in 'q', with: ''
      click_on 'search'
      click_on 'An American marriage / a novel by Tayari Jones'
      expect(page.text).to match(/← Previous | [0-9]+ of [0-9]+ | Next →/)

      # Go to the number 6 result separately
      visit '/catalog/24053587'
      expect(page).to have_no_css '.page-links'
      expect(page.text).not_to match(/← Previous | [0-9]+ of [0-9]+ | Next →/)
    end
  end
end
