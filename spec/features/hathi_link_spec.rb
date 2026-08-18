# frozen_string_literal: true

require 'rails_helper'
require 'support/vcr'

RSpec.describe 'Hathi Link', :js, :vcr do
  before do
    allow_any_instance_of(ExternalLinks::HathiLinkComponent).to receive(:search_item).and_return 'oclc/1234'
  end

  context 'when nothing is returned from HathiTrust' do
    it 'does not display Hathi Link' do
      visit 'catalog/3500414'
      expect(page).to have_css("img[src*='Springshare-LibGuide-Image']", visible: :hidden)
        .and have_css("div[data-search-item='oclc/1234']", visible: :hidden)
    end
  end

  context 'when a "Limited (search-only)" item is returned from HathiTrust' do
    it 'does not display Hathi Link' do
      visit 'catalog/3500414'
      expect(page).to have_css("img[src*='Springshare-LibGuide-Image']", visible: :hidden)
        .and have_css("div[data-search-item='oclc/1234']", visible: :hidden)
    end
  end

  context 'when a "Full view" item is returned from HathiTrust' do
    it 'does display Hathi Link' do
      visit 'catalog/3500414'
      expect(page).to have_css("img[src*='Springshare-LibGuide-Image']", visible: :visible)
        .and have_css("div[id='hathi-link']", visible: :visible)
        .and have_css("a[href*='https://babel.hathitrust.org/cgi/pt?id=abc1.123hjkl']",
                      visible: :visible)
        .and have_content('Full Text available online')
    end
  end
end
