# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Individual Record Genre', type: :feature do
  describe 'Individual record genre links', js: true do
    before do
      visit '/catalog/22080733'
    end

    it 'has a list of record genres' do
      # expect genres (field 655)
      expect(page).to have_content 'Domestic fiction'
      expect(page).to have_content 'Fiction'
      #genre does not have women-fiction (technically genre MARC field 650 but displayed in subject)
    end

    it 'links to that genre' do 
      click_on 'Domestic Fiction'
      expect(page).to have_selector 'article[data-document-id="22080733"]'
      expect(page).to have_selector 'article[data-document-id="2052181"]'
    end
  end
end
