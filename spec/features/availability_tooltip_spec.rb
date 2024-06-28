# frozen_string_literal: true

require 'rails_helper'
require 'support/vcr'

RSpec.describe 'Availability Tooltip', :vcr do
  before do
    stub_request(:get, /https:\/\/catalog.hathitrust.org\/api\/volumes\/brief\//)
    Settings.readonly = false
    Settings.hide_hold_button = false
    Settings.hide_etas_holdings = false
  end

  describe 'Clicking "View More" and hovering over tooltip', :js do
    it 'renders tooltip' do
      visit '/catalog/2169033'
      click_on 'View More'
      sleep(0.5)
      find('i[data-toggle="tooltip"]').hover
      expect(find('i[aria-describedby^="tooltip"]')).to be_present
      expect(page).to have_content('Pagination in this v.2 is off by 3 from original')
    end
  end
end
