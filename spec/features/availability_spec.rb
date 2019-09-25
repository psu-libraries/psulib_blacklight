# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Availability', type: :feature do
  describe 'User searches for a record' do
    it 'that has holdings to display', js: true do
      visit '/?utf8=✓&search_field=all_fields&q=0802132138+AND+1st+Grove+Weidenfeld+Evergreen+ed'
      expect(page).to have_css('button[data-target="#availability-1839879"]')
    end

    it 'that is an online resource and has no holdings to display', js: true do
      visit '/?utf8=✓&search_field=all_fields&q=D-humanos+Arruti%2C+Mariana'
      expect(page).not_to have_css('button[data-target="#availability-22091400"]')
    end
  end

  describe 'User opens the item page for a record' do
    it 'that has holdings to display', js: true do
      visit '/catalog/1839879'
      expect(page).to have_css('div[class="availability-holdings"]')
    end

    it 'that is an online resource and has no holdings to display', js: true do
      visit '/catalog/22091400'
      expect(page).not_to have_css('div[class="availability-holdings"]')
    end
  end
end
