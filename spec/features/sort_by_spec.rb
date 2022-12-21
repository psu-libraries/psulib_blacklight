# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Sort by', type: :feature do
  describe 'search result page', js: true do
    before do
      visit '/?search_field=all_fields&q=history'
    end

    context 'when sort by purchase date is selected' do
      before do
        click_on 'Sort by relevance'
        click_on 'purchase date'
      end

      it 'displays the correct headers' do
        expect(page).to have_content 'Sort by purchase date'
      end

      it 'displays results content' do
        within '#documents' do
          expect(page).to have_selector 'article[data-document-id="31805621"]'
          expect(page).not_to have_selector 'article[data-document-id="11160284"]'
        end
      end
    end
  end
end
