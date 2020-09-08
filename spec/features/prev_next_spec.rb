# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Previous Next Toggle', type: :feature do
  describe 'Previous next links toggle', js: true do
    it 'does not display stale previous and next links for direct item views' do
      visit root_path
      fill_in 'q', with: ''
      click_button 'search'
      click_on 'Analytical methods for Kolmogorov equations / Luca Lorenzi, University of Parma, Italy'
      expect(page).to have_content '← Previous | 5 of 531 | Next →'

      # Go to the number 9 result separately
      visit '/catalog/22083276'
      expect(page).not_to have_selector '.page-links'
      expect(page).not_to have_content '← Previous | 5 of 531 | Next →'
    end
  end
end
