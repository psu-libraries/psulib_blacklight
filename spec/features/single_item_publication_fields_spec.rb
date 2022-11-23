# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Single Item Publication Fields', type: :feature do
  describe 'Single item publication fields', js: true do
    context 'when the item has multiple indicators for MARC field 264' do
      before do
        visit '/catalog/19437'
      end

      it 'they are each displayed under the correct labels' do
        within '.blacklight-overall_imprint_display_ssm' do
          expect(page).to have_content 'New York : P. Smith, 1948.'
        end
        within '.blacklight-copyright_display_ssm' do
          expect(page).to have_content '[©1932]'
        end
      end
    end

    context 'when the item has MARC field 260 instead of 264' do
      before do
        visit '/catalog/839980'
      end

      it 'displays the data for MARC field 260 within Published' do
        within '.blacklight-overall_imprint_display_ssm' do
          expect(page).to have_content 'New York : Harper, [1959].'
        end
      end
    end

    context 'when the item has limited publicaton data' do
      before do
        visit '/catalog/29249541'
      end

      it 'does not display missing fields' do
        expect(page).not_to have_content 'Copyright Date:'
      end
    end

    context 'when the item has full publication data' do
      before do
        visit '/catalog/22080733'
      end

      it 'displays each field within the appropriate label' do
        within '.blacklight-overall_imprint_display_ssm' do
          expect(page).to have_content 'Chapel Hill, North Carolina : Algonquin Books of Chapel Hill, 2018.'
        end
        within '.blacklight-copyright_display_ssm' do
          expect(page).to have_content '2018'
        end
        within '.blacklight-edition_display_ssm' do
          expect(page).to have_content 'First edition.'
        end
      end
    end
  end
end
