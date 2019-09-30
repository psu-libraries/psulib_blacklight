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

  describe 'User opens a record with many holdings in a library' do
    it 'toggles 4 or more holdings with View More/View Less button', js: true do
      visit '/catalog/1793712'
      within('div[data-library="UP-MICRO"]') do
        expect(page).to have_selector('button', text: /View More/)
        expect(page).not_to have_selector('button', text: /View Less/)
        expect(page).to have_xpath('.//tbody/tr', :count => 4)
        click_button('View More')
        sleep 1 # let collapse animation finish and wait for it to re-collapse
        expect(page).to have_xpath('.//tbody/tr', :count => 28)
        expect(page).to have_selector('button', text: /View Less/)
        click_button('View Less')
        expect(page).to have_xpath('.//tbody/tr', :count => 4)
      end
    end
  end

  describe 'User request items with Aeon:' do
    it 'uses Request Material link for archival materials', js: true do
      visit '/catalog/1836205'
      expect(page).to have_css('a[data-type="aeon-link"][data-call-number="RBM 2457 box1 AX/SP/10155/11"]')
      expect(page).to have_link(
                          'Request Material',
                          href: 'https://aeon.libraries.psu.edu/Logon/?Action=10&Form=30&ReferenceNumber='\
                                '1836205&Genre=ARCHIVES&Location=Stored%20offsite.%20Ask%20at%20Special%20'\
                                'Collections%2C%20104%20Paterno&ItemNumber=000076995675&CallNumber='\
                                'RBM%202457%20box1%20AX%2FSP%2F10155%2F11&ItemTitle=Fiona%20Pitt-Kethley%20'\
                                'literary%20papers&ItemAuthor=Pitt-Kethley%2C%20Fiona%2C%201954-&ItemEdition'\
                                '=&ItemPublisher=&ItemPlace=&ItemDate=&ItemInfo1=Unrestricted%20access.')
    end

    it 'uses Request Scan links for archival thesis'
  end

  describe 'Holdings and Availability Bound Withs:' do
    it 'displays holding with parents info'
  end
end
