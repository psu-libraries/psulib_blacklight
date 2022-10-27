# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Advanced Search', type: :feature do
  describe 'User uses advanced search', js: true do
    before do
        #direct to advance search
    end 

    describe 'single term searches', js: true do 
      before do
        #initiate actual search
      end 

      context 'when searching by series title' do
        before do
            #search in field 'series' for term: 'Black studies & critical thinking'
        end 

        it 'results include expected CAT keys' do
          #expect statements for 22861023 and 22861022
        end
      end 

      context 'when searching by series keyword' do
        before do
            #search in field 'series' for term: critical thinking
        end 

        it 'results include expected CAT keys' do
          #expect statements for 22861023 and 22861022
        end
      end 

      context 'when searching by isbn' do
        before do
            #search in field 'identifiers' for term: 9780820330365 
        end 

        it 'results include expected CAT keys' do
          #expect statements for 4436334
        end
      end 

      context 'when searching by issn' do
        before do
            #search in field 'identifiers' for term 0003-4843 or 00034843
        end 

        it 'results include expected CAT keys' do
          #expect statements for 717714
        end
      end 

      context 'when searching by publisher' do
        before do
            #search in field 'publisher' for term 'Peter Lang'
        end 

        it 'results include expected CAT keys' do
          #expect statements for 4660904, 1742958, 23794738 (may be pretty far back in search results)
        end
      end 

      context 'when searching by a single publication date' do
        before do
            #search in field 'range[pub_date_itsi][begin]=' for term '2022'
        end 

        it 'results include expected CAT keys' do
          #expect statements for 38337883
        end
      end 

      context 'when searching by publication date range' do
        before do
            #search in field 'range%5Bpub_date_itsi%5D%5Bbegin%5D=2022&range%5Bpub_date_itsi%5D%5Bend%5D=2023
        end 

        it 'results include expected CAT keys' do
          #expect statements for 38337883
        end
      end 

    end 
    
    describe 'combination searches', js: true do
      before do
        #conditions for combination search
      end  
        
      context 'when searching by publication date range' do
        before do
           #search in field 'range%5Bpub_date_itsi%5D%5Bbegin%5D=2022&range%5Bpub_date_itsi%5D%5Bend%5D=2023
        end 
    
        it 'results include expected CAT keys' do
          #expect statements for 38337883
        end
      end 
    end

    describe 'vernacular language', js: true do
        before do
          #conditions for vernacular language search
        end  
          
        context 'when searching in simplified chinese' do
          before do
             #search in field 'title' with term 广西壮族自治区地图
          end 
      
          it 'results include expected CAT keys' do
            #expect statements for 12348543
          end
        end 

        context 'when searching in traditional chinese' do
            before do
               #search in field 'title' with term 廣西壯族自治區地圖
            end 
        
            it 'results include expected CAT keys' do
              #expect statements for 12348543
            end
          end 
    end

    # should this be in another location?
    describe 'link to MARC view', js: true do
      before do
        #navigate through search to a record page (23794738)
      end

      it 'record page contains link to MARC record' do
        #expect page to contain https://catalog.libraries.psu.edu/catalog/23794738/marc_view 
      end
    end
  end
end