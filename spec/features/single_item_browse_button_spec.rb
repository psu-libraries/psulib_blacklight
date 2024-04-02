# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Single Item Browse Button' do
  context 'when record has one LC call number', :js do
    before do
      visit '/catalog/22080733'
    end

    it 'displays browse button for LC call number' do
      expect(page).to have_no_css('button[data-toggle=dropdown]')
      expect(page).to have_link('Browse Nearby on Shelf',
                                href: '/browse/call_numbers?classification=lc&nearby=PS3610.O63A84+2018')
    end
  end

  context 'when record has multiple LC call numbers', :js do
    before do
      visit '/catalog/53953'
    end

    it 'displays browse button for LC call numbers' do
      expect(page).to have_css('button[data-toggle=dropdown]')
      expect(page).to have_link('AP3.M33',
                                href: '/browse/call_numbers?classification=lc&nearby=AP3.M33',
                                visible: :hidden)
      expect(page).to have_link('AN502.L66M63',
                                href: '/browse/call_numbers?classification=lc&nearby=AN502.L66M63',
                                visible: :hidden)
    end
  end

  context 'when record has one Dewey call number', :js do
    before do
      visit '/catalog/1043229'
    end

    it 'displays browse button for Dewey call number' do
      expect(page).to have_no_css('button[data-toggle=dropdown]')
      expect(page).to have_link('Browse Nearby on Shelf',
                                href: '/browse/call_numbers?classification=dewey&nearby=111.85M35b')
    end
  end

  context 'when record has multiple Dewey call numbers', :js do
    before do
      visit '/catalog/307724'
    end

    it 'displays browse button for Dewey call numbers' do
      expect(page).to have_css('button[data-toggle=dropdown]')
      expect(page).to have_link('016.53976Un3i',
                                href: '/browse/call_numbers?classification=dewey&nearby=016.53976Un3i',
                                visible: :hidden)
      expect(page).to have_link('016.53976Un3i v.2',
                                href: '/browse/call_numbers?classification=dewey&nearby=016.53976Un3i+v.2',
                                visible: :hidden)
    end
  end

  context 'when record has multiple LC and Dewey call numbers', :js do
    before do
      visit '/catalog/423287'
    end

    it 'displays browse button for LC call numbers' do
      expect(page).to have_css('button[data-toggle=dropdown]')
      expect(page).to have_link('HQ1061.M5 Selections',
                                href: '/browse/call_numbers?classification=lc&nearby=HQ1061.M5+Selections',
                                visible: :hidden)
      expect(page).to have_link('HQ1061.M5',
                                href: '/browse/call_numbers?classification=lc&nearby=HQ1061.M5',
                                visible: :hidden)
    end
  end
end
