# frozen_string_literal: true

require 'rails_helper'
require 'support/vcr'

RSpec.describe 'Availability Tooltip', :vcr, type: :feature do
  before do
    Settings.hathi_etas = false
    Settings.readonly = false
    Settings.hide_hold_button = false
    Settings.hide_etas_holdings = false
  end

  describe 'Clicking "View More" and hovering over tooltip', js: true do
    it 'renders tooltip' do
      visit '/catalog/2169033'
      click_button 'View More'
      sleep(0.5)
      find('i[data-toggle="tooltip"]').hover
      expect(find('i[aria-describedby^="tooltip"]')).to be_present
      expect(page).to have_content('Pagination in this v.2 is off by 3 from original')
    end
  end
end
