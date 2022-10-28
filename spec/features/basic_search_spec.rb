# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Basic Search', type: :feature do
  describe 'User uses basic search', js: true do

    describe 'searching by title', js: true do
      before do
        visit '/?search_field=title&q='
      end

      context 'when searching by title' do
        before do
          # switch TITLE with search term
          fill_in 'q', with: 'TITLE'
          click_button 'search'
        end 
      
        it 'results include expected CAT keys' do
          # switch CATKEY with number
          expect(page).to have_selector 'article[data-document-id="CATKEY"]'
          expect(page).to have_selector 'article[data-document-id="CATKEY"]'
        end
      end

      context 'when searching by title series without quotes' do
        before do
          # switch TITLE with search term
          fill_in 'q', with: 'TITLE'
          click_button 'search'
        end 
        
        it 'results include expected CAT keys' do
          # switch CATKEY with number
          expect(page).to have_selector 'article[data-document-id="CATKEY"]'
          expect(page).to have_selector 'article[data-document-id="CATKEY"]'
        end
      end

      context 'when searching by alternate title' do
        before do
          # switch TITLE with search term
          fill_in 'q', with: 'TITLE'
          click_button 'search'
        end 
        
        it 'results include expected CAT keys' do
          # switch CATKEY with number
          expect(page).to have_selector 'article[data-document-id="CATKEY"]'
        end
      end

      context 'when searching by former title' do
        before do
          # switch TITLE with search term
          fill_in 'q', with: 'TITLE'
          click_button 'search'
        end 
        
        it 'results include expected CAT keys' do
          # switch CATKEY with number
          expect(page).to have_selector 'article[data-document-id="CATKEY"]'
        end
      end

      context 'when searching by related title' do
        before do
          # switch TITLE with search term
          fill_in 'q', with: 'TITLE'
          click_button 'search'
        end 
        
        it 'results include expected CAT keys' do
          # switch CATKEY with number
          expect(page).to have_selector 'article[data-document-id="CATKEY"]'
        end
      end
    end

    describe 'searching by author', js: true do
      before do
        visit '/?search_field=author&q='
      end

      context 'when searching by person author (natural order)' do
        before do
          # switch AUTHOR with search term
          fill_in 'q', with: 'AUTHOR'
          click_button 'search'
        end 
        
        it 'results include expected CAT keys' do
          # switch CATKEY with number
          expect(page).to have_selector 'article[data-document-id="CATKEY"]'
          expect(page).to have_selector 'article[data-document-id="CATKEY"]'
          expect(page).to have_selector 'article[data-document-id="CATKEY"]'
        end
      end

      context 'when searching by person author (inverted order)' do
        before do
          # switch AUTHOR with search term
          fill_in 'q', with: 'AUTHOR'
          click_button 'search'
        end 
        
        it 'results include expected CAT keys' do
          # switch CATKEY with number
          expect(page).to have_selector 'article[data-document-id="CATKEY"]'
          expect(page).to have_selector 'article[data-document-id="CATKEY"]'
          expect(page).to have_selector 'article[data-document-id="CATKEY"]'
        end
      end

      context 'when searching by corporate author' do
        before do
          # switch AUTHOR with search term
          fill_in 'q', with: 'AUTHOR'
          click_button 'search'
        end 
        
        it 'results include expected CAT keys' do
          # switch CATKEY with number
          expect(page).to have_selector 'article[data-document-id="CATKEY"]'
        end
      end

      context 'when searching by conference author' do
        before do
          # switch AUTHOR with search term
          fill_in 'q', with: 'AUTHOR'
          click_button 'search'
        end 
        
        it 'results include expected CAT keys' do
          # switch CATKEY with number
          expect(page).to have_selector 'article[data-document-id="CATKEY"]'
        end
      end

    end
    
    describe 'searching by subject', js: true do
      before do
        visit '/?search_field=subject&q='
      end

      context 'when using a basic search' do
        before do
          fill_in 'q', with: 'geology'
          click_button 'search'
        end 
  
        it 'results include expected CAT keys' do
          expect(page).to have_selector 'article[data-document-id="2680348"]'
          expect(page).to have_selector 'article[data-document-id="2724728"]'
        end
      end

      context 'when using a fuller search without quotes' do
        before do
          fill_in 'q', with: 'African American women'
          click_button 'search'
        end 
  
        it 'results include expected CAT keys' do
          expect(page).to have_selector 'article[data-document-id="24053587"]'
          expect(page).to have_selector 'article[data-document-id="22080733"]'
        end
      end

      context 'when using a fuller search with quotes' do
        before do
          fill_in 'q', with: '"African American women"'
          click_button 'search'
        end 
  
        it 'results include expected CAT keys' do
          expect(page).to have_selector 'article[data-document-id="24053587"]'
          expect(page).not_to have_selector 'article[data-document-id="22080733"]'
        end
      end


    end
  end
end