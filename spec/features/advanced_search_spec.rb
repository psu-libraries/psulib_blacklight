# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Advanced Search' do
  describe 'User uses advanced search', :js do
    before do
      visit '/advanced'
    end

    it 'renders an additional search button at the top of the form' do
      expect(page).to have_css 'form h1.page-header input#advanced-search-submit-top'
    end

    context 'when doing single term searches' do
      context 'when searching by series title' do
        before do
          fill_in 'clause_5_query', with: 'Yale studies in political science'
          click_on 'advanced-search-submit'
        end

        it 'results include expected CAT keys' do
          expect(page).to have_css 'article[data-document-id="1373276"]'
        end
      end

      context 'when searching by series keyword' do
        before do
          fill_in 'clause_5_query', with: 'political science'
          click_on 'advanced-search-submit'
        end

        it 'results include expected CAT keys' do
          expect(page).to have_css 'article[data-document-id="1373276"]'
        end
      end

      context 'when searching by isbn' do
        before do
          fill_in 'clause_4_query', with: '9780442290917'
          click_on 'advanced-search-submit'
        end

        it 'results include expected CAT keys' do
          expect(page).to have_css 'article[data-document-id="1069788"]'
        end
      end

      context 'when searching by issn' do
        before do
          fill_in 'clause_4_query', with: '10756787'
          click_on 'advanced-search-submit'
        end

        it 'results include expected CAT keys' do
          expect(page).to have_css 'article[data-document-id="1443986"]'
        end
      end

      context 'when searching by LCCN' do
        before do
          fill_in 'clause_4_query', with: '2001270122'
          click_on 'advanced-search-submit'
        end

        it 'results include expected CAT keys' do
          expect(page).to have_css 'article[data-document-id="2250425"]'
        end
      end

      context 'when searching by publisher' do
        before do
          fill_in 'clause_6_query', with: 'Norton'
          click_on 'advanced-search-submit'
        end

        it 'results include expected CAT keys' do
          expect(page).to have_css 'article[data-document-id="2069311"]'
        end
      end

      context 'when searching by a single publication date' do
        before do
          fill_in 'range_pub_date_itsi_begin', with: '2017'
          click_on 'advanced-search-submit'
        end

        it 'results include expected CAT keys' do
          expect(page).to have_css 'article[data-document-id="31805602"]'
        end
      end

      context 'when searching by publication date range' do
        before do
          fill_in 'range_pub_date_itsi_begin', with: '2017'
          fill_in 'range_pub_date_itsi_end', with: '2018'
          click_on 'advanced-search-submit'
        end

        it 'results include expected CAT keys' do
          expect(page).to have_css 'article[data-document-id="31805602"]'
          expect(page).to have_css 'article[data-document-id="31805615"]'
        end
      end
    end

    context 'when doing combination searches' do
      context 'when searching for a specific book about quilts in Cumberland County' do
        before do
          fill_in 'clause_1_query', with: 'quilts cumberland'
          fill_in 'clause_2_query', with: 'quilters'
          find('button[data-id="access_facet"]').click
          find_by_id('bs-select-1-1').click
          find('button[data-id="format"]').click
          find_by_id('bs-select-2-3').click
          find('button[data-id="language_facet"]').click
          find_by_id('bs-select-3-4').click
          find('button[data-id="lc_1letter_facet"]').click
          find_by_id('bs-select-5-12').click
          click_on 'advanced-search-submit'
        end

        it 'results include expected CAT keys' do
          expect(page).to have_css 'article[data-document-id="18648055"]'
        end
      end

      context 'when searching for a specific book on geological perspectives of climate change' do
        before do
          fill_in 'clause_3_query', with: 'Climatology'
          fill_in 'clause_5_query', with: 'AAPG studies in geology'
          fill_in 'clause_6_query', with: 'Petroleum Geologists'
          find('button[data-id="library_facet"]').click
          find_by_id('bs-select-6-4').click
          click_on 'advanced-search-submit'
        end

        it 'results include expected CAT keys' do
          expect(page).to have_css 'article[data-document-id="2250425"]'
        end
      end
    end

    context 'when using vernacular language' do
      context 'when searching in simplified chinese' do
        before do
          fill_in 'clause_1_query', with: '上海理论'
          click_on 'advanced-search-submit'
        end

        it 'results include expected CAT keys' do
          expect(page).to have_css 'article[data-document-id="17280643"]'
        end
      end

      context 'when searching in traditional chinese' do
        before do
          fill_in 'clause_1_query', with: '上海理論'
          click_on 'advanced-search-submit'
        end

        it 'results include expected CAT keys' do
          expect(page).to have_css 'article[data-document-id="17280643"]'
        end
      end
    end
  end
end
