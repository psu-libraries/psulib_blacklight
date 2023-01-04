# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Sort by', type: :feature do
  describe 'search result page', js: true do
    before do
      visit '/?search_field=all_fields&q=history'
      click_on 'Sort by relevance'
    end

    context 'when sort by relevance is selected' do
      before do
        click_on 'relevance'
      end

      it 'displays the correct headers' do
        expect(page).to have_content 'Sort by relevance'
      end

      it 'displays results content' do
        within '#documents' do
          expect(page).to have_selector 'article[data-document-id="11160284"]'
        end
      end
    end

    context 'when sort by year is selected' do
      before do
        click_on 'year'
      end

      it 'displays the correct headers' do
        expect(page).to have_content 'Sort by year'
      end

      it 'displays results content' do
        within '#documents' do
          expect(page).to have_selector 'article[data-document-id="21601671"]'
        end
      end
    end

    context 'when sort by title is selected' do
      before do
        click_on 'title'
      end

      it 'displays the correct headers' do
        expect(page).to have_content 'Sort by title'
      end

      it 'displays results content' do
        within '#documents' do
          expect(page).to have_selector 'article[data-document-id="1293861"]'
        end
      end
    end

    context 'when sort by purchase date is selected' do
      before do
        click_on 'purchase date'
      end

      it 'displays the correct headers' do
        expect(page).to have_content 'Sort by purchase date'
      end

      it 'displays results content' do
        within '#documents' do
          expect(page).to have_selector 'article[data-document-id="27422489"]'
          expect(page).not_to have_selector 'article[data-document-id="11160284"]'
        end
      end
    end
  end
end
