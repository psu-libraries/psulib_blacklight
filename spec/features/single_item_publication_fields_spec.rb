# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Single Item Publication Fields', type: :feature do
  describe 'Single item publication fields', js: true do

    context 'when the item has multiple indicators for MARC field 264' do
      before do
        visit '/catalog/19437'
      end

      it 'they are each displayed under the correct labels' do
        #expect 264 1 under published
        #expect 264 4 under copyright
      end
    end

    context 'when the item has MARC field 260 instead of 264' do
      before do
        visit '/catalog/839980'
      end

      it 'displays the data for MARC field 260 within Published' do
        #within 'Published'
          #expect(page).to have_content 'MARC 260 CONTENT'
        #end 
      end 
    end

    context 'when the item has limited publicaton data' do
      before do
        visit '/catalog/29249541'
      end

      it 'does not display missing fields' do
        #expect not to have missing fields
      end
    end

    context 'when the item has full publication data' do
      before do
        visit '/catalog/19437'
      end

      it 'displays each field within the appropriate label' do
        #within 'Published'
          #expect content
        #end  
      end
    end 
  end
end
