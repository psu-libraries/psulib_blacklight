# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Advanced Search', type: :feature do
  describe 'User uses advanced search', js: true do
    before do
      visit '/advanced'
    end 

    describe 'single term searches', js: true do 

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
=begin
      context 'when searching by a single publication date' do
        before do
            #field 'range[pub_date_itsi][begin]=', with: '2017'
            click_button 'advanced-search-submit'
        end 

        it 'results include expected CAT keys' do
          expect(page).to have_selector 'article[data-document-id="31805602"]'
        end
      end 

      context 'when searching by publication date range' do
        before do
            #field 'range%5Bpub_date_itsi%5D%5Bbegin%5D=2017&range%5Bpub_date_itsi%5D%5Bend%5D=2018'
        end 

        it 'results include expected CAT keys' do
          expect(page).to have_selector 'article[data-document-id="31805602"]'
          expect(page).to have_selector 'article[data-document-id="31805615"]'
        end
      end 
=end
    end 
    
    describe 'combination searches', js: true do
        
      context 'when searching for a specific book about quilts in Cumberland County' do
        before do
          fill_in 'title', with: 'quilts cumberland'
          fill_in 'author', with: 'quilters'
          #fill_in 'facet-access_facet' with: 'In the Library'
          #facets go here
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
          select 'In the Library', from: 'facet-access_facet'
          #facets go here
          click_button 'advanced-search-submit'
        end  
    
        it 'results include expected CAT keys' do
          expect(page).to have_selector 'article[data-document-id="2250425"]'
        end
      end 
    end

    describe 'vernacular language', js: true do

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

    # should this be in another location?
    describe 'link to MARC view', js: true do
      before do
        visit '/catalog/24053587'
      end

      it 'record page contains link to MARC record' do
       expect(page).to have_selector  'a[id="marc_record_link"]'
       expect(page).to have_selector  'a[href="/catalog/24053587/marc_view"]'
      end
    end
  end
end