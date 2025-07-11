# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Single Item Genre' do
  describe 'Single item genre links', :js do
    before do
      visit '/catalog/22080733'
    end

    it 'has a list of item genres' do
      within 'dd.blacklight-genre_display_ssm.ms-5' do
        expect(page).to have_content 'Domestic fiction'
        expect(page).to have_content 'Fiction'
        expect(page).to have_no_content 'FICTION / Women'
      end
    end

    it 'links to that genre' do
      sleep 0.5
      click_on 'Domestic fiction'
      expect(page).to have_css 'article[data-document-id="22080733"]'
      expect(page).to have_css 'article[data-document-id="2052181"]'
    end
  end
end
