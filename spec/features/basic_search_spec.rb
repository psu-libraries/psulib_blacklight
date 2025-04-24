# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Basic Search' do
  describe 'User uses basic search', :js do
    context 'when searching by title' do
      before do
        visit '/?search_field=title&q='
      end

      context 'when searching by title' do
        before do
          fill_in 'q', with: 'Becoming'
          click_on 'search'
        end

        it 'results include expected CAT keys' do
          expect(page).to have_css 'article[data-document-id="24053587"]'
          expect(page).to have_css 'article[data-document-id="3626147"]'
        end
      end

      context 'when searching by title series without quotes' do
        before do
          fill_in 'q', with: 'IEEE standards'
          click_on 'search'
        end

        it 'results include expected CAT keys' do
          expect(page).to have_css 'article[data-document-id="2290006"]'
        end
      end

      context 'when searching by alternate title' do
        before do
          fill_in 'q', with: 'Blind swordsman'
          click_on 'search'
        end

        it 'results include expected CAT keys' do
          expect(page).to have_css 'article[data-document-id="12133574"]'
        end
      end

      context 'when searching by former title' do
        before do
          fill_in 'q', with: 'Washington post and times herald'
          click_on 'search'
        end

        it 'results include expected CAT keys' do
          expect(page).to have_css 'article[data-document-id="114189"]'
        end
      end

      context 'when searching by related title' do
        before do
          fill_in 'q', with: 'Bear Cove Head to Brigus South'
          click_on 'search'
        end

        it 'results include expected CAT keys' do
          expect(page).to have_css 'article[data-document-id="24798226"]'
        end
      end
    end

    context 'when searching by author' do
      before do
        visit '/?search_field=author&q='
      end

      context 'when searching by person author (natural order)' do
        before do
          fill_in 'q', with: 'Michelle Obama'
          click_on 'search'
        end

        it 'results include expected CAT keys' do
          expect(page).to have_css 'article[data-document-id="24053587"]'
        end
      end

      context 'when searching by person author (inverted order)' do
        before do
          fill_in 'q', with: 'Obama, Michelle'
          click_on 'search'
        end

        it 'results include expected CAT keys' do
          expect(page).to have_css 'article[data-document-id="24053587"]'
        end
      end

      context 'when searching by corporate author' do
        before do
          fill_in 'q', with: 'Pennsylvania Institution for the Instruction of the Blind'
          click_on 'search'
        end

        it 'results include expected CAT keys' do
          expect(page).to have_css 'article[data-document-id="79172"]'
        end
      end

      context 'when searching by conference author' do
        before do
          fill_in 'q', with: 'IEEE International Frequency Control Symposium'
          click_on 'search'
        end

        it 'results include expected CAT keys' do
          expect(page).to have_css 'article[data-document-id="1443986"]'
        end
      end

      context 'when searching by author (vernacular)' do
        before do
          fill_in 'q', with: '新聞局'
          click_on 'search'
        end

        it 'results include expected CAT keys' do
          expect(page).to have_css 'article[data-document-id="6844545"]'
        end
      end
    end

    context 'when searching by subject' do
      before do
        visit '/?search_field=subject&q='
      end

      context 'when using a basic search' do
        before do
          fill_in 'q', with: 'geology'
          click_on 'search'
        end

        it 'results include expected CAT keys' do
          expect(page).to have_css 'article[data-document-id="2680348"]'
          expect(page).to have_css 'article[data-document-id="2724728"]'
        end
      end

      context 'when using a fuller search without quotes' do
        before do
          fill_in 'q', with: 'African American women lawyers--Illinois--Chicago--Biography'
          click_on 'search'
        end

        it 'results include expected CAT keys' do
          expect(page).to have_css 'article[data-document-id="24053587"]'
        end
      end

      context 'when using a fuller search with quotes' do
        before do
          fill_in 'q', with: '"African American women"'
          click_on 'search'
        end

        it 'results include expected CAT keys' do
          expect(page).to have_css 'article[data-document-id="24053587"]'
          expect(page).to have_no_css 'article[data-document-id="22080733"]'
        end
      end
    end
  end
end
