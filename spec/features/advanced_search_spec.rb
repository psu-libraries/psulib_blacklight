# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Advanced Search', type: :feature do
  describe 'User uses advanced search', js: true do
    before do
      visit '/advanced'
    end

    context 'when doing single term searches' do
      context 'when searching by series title' do
        before do
          fill_in 'series', with: 'Yale studies in political science'
          click_button 'advanced-search-submit'
        end

        it 'results include expected CAT keys' do
          expect(page).to have_selector 'article[data-document-id="1373276"]'
        end
      end

      context 'when searching by series keyword' do
        before do
          fill_in 'series', with: 'political science'
          click_button 'advanced-search-submit'
        end

        it 'results include expected CAT keys' do
          expect(page).to have_selector 'article[data-document-id="1373276"]'
        end
      end

      context 'when searching by isbn' do
        before do
          fill_in 'identifiers', with: '9780442290917'
          click_button 'advanced-search-submit'
        end

        it 'results include expected CAT keys' do
          expect(page).to have_selector 'article[data-document-id="1069788"]'
        end
      end

      context 'when searching by issn' do
        before do
          fill_in 'identifiers', with: '10756787'
          click_button 'advanced-search-submit'
        end

        it 'results include expected CAT keys' do
          expect(page).to have_selector 'article[data-document-id="1443986"]'
        end
      end

      context 'when searching by LCCN' do
        before do
          fill_in 'identifiers', with: '2001270122'
          click_button 'advanced-search-submit'
        end

        it 'results include expected CAT keys' do
          expect(page).to have_selector 'article[data-document-id="2250425"]'
        end
      end

      context 'when searching by publisher' do
        before do
          fill_in 'publisher', with: 'Norton'
          click_button 'advanced-search-submit'
        end

        it 'results include expected CAT keys' do
          expect(page).to have_selector 'article[data-document-id="2069311"]'
        end
      end

      context 'when searching by a single publication date' do
        before do
          fill_in 'range_pub_date_itsi_begin', with: '2017'
          click_button 'advanced-search-submit'
        end

        it 'results include expected CAT keys' do
          expect(page).to have_selector 'article[data-document-id="31805602"]'
        end
      end

      context 'when searching by publication date range' do
        before do
          fill_in 'range_pub_date_itsi_begin', with: '2017'
          fill_in 'range_pub_date_itsi_end', with: '2018'
          click_button 'advanced-search-submit'
        end

        it 'results include expected CAT keys' do
          expect(page).to have_selector 'article[data-document-id="31805602"]'
          expect(page).to have_selector 'article[data-document-id="31805615"]'
        end
      end
    end

    context 'when doing combination searches' do
      context 'when searching for a specific book about quilts in Cumberland County' do
        before do
          fill_in 'title', with: 'quilts cumberland'
          fill_in 'author', with: 'quilters'
          find('button[data-id="access_facet"]').click
          find('#bs-select-1-1').click
          find('button[data-id="format"]').click
          find('#bs-select-2-3').click
          find('button[data-id="language_facet"]').click
          find('#bs-select-3-4').click
          find('button[data-id="lc_1letter_facet"]').click
          find('#bs-select-5-12').click
          click_button 'advanced-search-submit'
        end

        it 'results include expected CAT keys' do
          expect(page).to have_selector 'article[data-document-id="18648055"]'
        end
      end

      context 'when searching for a specific book on geological perspectives of climate change' do
        before do
          fill_in 'subject', with: 'Climatology'
          fill_in 'series', with: 'AAPG studies in geology'
          fill_in 'publisher', with: 'Petroleum Geologists'
          find('button[data-id="library_facet"]').click
          find('#bs-select-6-4').click
          click_button 'advanced-search-submit'
        end

        it 'results include expected CAT keys' do
          expect(page).to have_selector 'article[data-document-id="2250425"]'
        end
      end
    end

    context 'when using vernacular language' do
      context 'when searching in simplified chinese' do
        before do
          fill_in 'title', with: '上海理论'
          click_button 'advanced-search-submit'
        end

        it 'results include expected CAT keys' do
          expect(page).to have_selector 'article[data-document-id="17280643"]'
        end
      end

      context 'when searching in traditional chinese' do
        before do
          fill_in 'title', with: '上海理論'
          click_button 'advanced-search-submit'
        end

        it 'results include expected CAT keys' do
          expect(page).to have_selector 'article[data-document-id="17280643"]'
        end
      end
    end
  end
end
