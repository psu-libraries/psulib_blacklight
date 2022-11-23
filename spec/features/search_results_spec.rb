# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Search Results', type: :feature do
  describe 'search result page', js: true do
    before do
      visit '/?search_field=all_fields&q=history'
    end
    
    it 'displays the correct headers' do
      expect(page).to have_content 'Sort by relevance'
      expect(page).to have_content 'per page'
    end

    it 'displays the search constraints' do
      within '#appliedParams' do
        expect(page).to have_content 'history'
        expect(page).to have_link '✖'
      end
    end

    context 'when there are results to display' do
      it 'displays results content' do
        within '#documents' do
          expect(page).to have_selector 'article[data-document-id="124958"]'
          expect(page).not_to have_content 'No results found for your search'
        end
      end
    end 

    context 'when there are no results to display' do
      before do
        visit '/?search_field=all_fields&q=kinesiology'
      end

      it 'displays content for "no results found"' do
        within '#documents' do
          expect(page).to have_content 'No results found for your search'
          expect(page).to have_link 'All of LionSearch'
          expect(page).to have_link 'Libraries worldwide (WorldCat)'
          expect(page).to have_link 'Public domain books and journals: HathiTrust'
          expect(page).to have_link 'Articles: Google Scholar'
          expect(page).not_to have_selector 'article[data-document-id="124958"]'
        end
      end
    end
  end
end
