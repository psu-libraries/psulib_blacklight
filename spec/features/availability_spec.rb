# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Availability', type: :feature do
  describe 'User searches for a record', js: true do
    it 'that has holdings and a \'View Availability\' button' do
      visit '/?utf8=✓&search_field=all_fields&q=9781599901091'
      expect(page).to have_selector 'button[data-target="#availability-5112336"]'
    end

    it 'that has holdings but none are available' do
      visit '/?utf8=✓&search_field=all_fields&q=Eva+Oper+in+drei+Akten'
      # Shouldn't show the location teaser text next to the show availability button
      expect(page).not_to have_selector '.availability-snippet'
    end

    it 'that has holdings available in 3 or more locations' do
      visit '/?utf8=✓&search_field=all_fields&q=0802132138'
      expect(page).to have_selector '.availability-snippet',
                                    exact_text: 'Multiple Locations'
    end

    it 'that has holdings available in exactly 2 locations' do
      visit '/?utf8=✓&search_field=all_fields&q=0060125896'
      expect(page).to have_selector '.availability-snippet',
                                    exact_text: 'Altoona, Pattee Library and Paterno Library Stacks'
    end

    it 'that has holdings available in only 1 location' do
      visit '/?utf8=✓&search_field=all_fields&q=9780147513861'
      expect(page).to have_selector '.availability-snippet',
                                    exact_text: 'Pattee Library and Paterno Library Stacks'
    end

    it 'and clicks the \'View Availability\' button to display and hide holdings' do
      visit '/?utf8=✓&search_field=all_fields&q=9781599901091'
      expect(page).to have_selector 'button[data-target="#availability-5112336"]'
      expect(page).not_to have_selector '.availability-5112336'
      click_button('View Availability')
      expect(page).not_to have_selector '.availability-5112336', wait: 3
      expect(page).to have_content 'PZ8.G3295Su 2008'
      expect(page).to have_content 'Fiction G4672sun 2008'
    end

    it 'that is an online resource and has no holdings to display' do
      visit '/?utf8=✓&search_field=all_fields&q=D-humanos+Arruti%2C+Mariana'
      expect(page).not_to have_selector('button[data-target="#availability-22091400"]')
      expect(page).not_to have_selector '.availability-22091400'
    end
  end

  describe 'User opens the item page for a record' do
    it 'that has holdings to display', js: true do
      visit '/catalog/1839879'
      expect(page).to have_selector 'div[class="availability"][data-keys="1839879"]'
    end

    it 'that is an online resource and has no holdings to display', js: true do
      visit '/catalog/22091400'
      expect(page).not_to have_selector 'div[class="availability"]'
    end
  end

  describe 'User opens a record with many holdings in a library' do
    it 'toggles 4 or more holdings with View More/View Less button', js: true do
      visit '/catalog/1793712'
      within 'div[data-library="UP-MICRO"]' do
        expect(page).to have_selector 'button', text: /View More/
        expect(page).not_to have_selector 'button', text: /View Less/
        expect(page).to have_xpath './/tbody/tr', count: 4
        click_button('View More')
        sleep 1 # let collapse animation finish and wait for it to re-collapse
        expect(page).to have_xpath './/tbody/tr', count: 28
        expect(page).to have_selector 'button', text: /View Less/
        click_button('View Less')
        expect(page).to have_xpath './/tbody/tr', count: 4
      end
    end
  end

  describe 'Archival Material:' do
    it 'has a \'Request Material\' link so it can be requested through Aeon', js: true do
      visit '/catalog/1836205'
      expect(page).to have_css 'a[data-type="aeon-link"][data-call-number="RBM 2457 box1 AX/SP/10155/11"]'
      expect(page).to have_link(
        'Request Material',
                          href: 'https://aeon.libraries.psu.edu/Logon/?Action=10&Form=30&ReferenceNumber='\
                                '1836205&Genre=ARCHIVES&Location=Stored%20offsite.%20Ask%20at%20Special%20'\
                                'Collections%2C%20104%20Paterno&ItemNumber=000076995675&CallNumber='\
                                'RBM%202457%20box1%20AX%2FSP%2F10155%2F11&ItemTitle=Fiona%20Pitt-Kethley%20'\
                                'literary%20papers&ItemAuthor=Pitt-Kethley%2C%20Fiona%2C%201954-&ItemEdition'\
                                '=&ItemPublisher=&ItemPlace=&ItemDate=&ItemInfo1=Unrestricted%20access.&SubLocation='
      )
    end

    it 'has a \'Request Material\' link with subLocation info', js: true do
      visit '/catalog/107'
      expect(page).to have_css 'a[data-type="aeon-link"][data-call-number="AP2.O354 1870/71"]'
      # The important part below is `&SubLocation=Christmas%3B%20Nathaniel%20Hawthorne` which fills out a hidden input
      # in the AEON request form.
      expect(page).to have_link(
        'Request Material',
                          href: 'https://aeon.libraries.psu.edu/Logon/?Action=10&Form=30&ReferenceNumber=107&'\
                                'Genre=BOOK&Location=Rare%20Books%20%26%20Mss%2C%201st%20Floor%20Paterno%2C%2'\
                                '0American%20Lit.%20Coll.&ItemNumber=000021534850&CallNumber=AP2.O354%201870%'\
                                '2F71&ItemTitle=The%20Christmas%20locket&ItemAuthor=&ItemEdition=&ItemPublish'\
                                'er=Roberts%20brothers&ItemPlace=Boston&ItemDate=1870-&ItemInfo1=&SubLocation'\
                                '=Christmas%3B%20Nathaniel%20Hawthorne'
      )
    end
  end

  describe 'Archival Thesis:', js: true do
    it 'has links for requesting scans' do
      visit '/catalog/123730'
      within 'div[data-library="UP-ANNEX"]' do
        expect(page).to have_link(
          'Request Scan - Penn State Users',
                            href: 'https://psu-illiad-oclc-org.ezaccess.libraries.psu.edu/illiad/upm/illiad.dll/'\
                                  'OpenURL?Action=10&Form=20&Genre=GenericRequestThesisDigitization&title=Ecology'\
                                  '%20of%20the%20wild-trapped%20and%20transplanted%20ring-necked%20pheasant%20near'\
                                  '%20Centre%20Hall%2C%20Pennsylvania&callno=Thesis%201968mMyers%2CJE&rfr_id=info'\
                                  '%3Asid%2Fcatalog.libraries.psu.edu&aulast=Myers%2C%20James%20E.&date=1968'
        )
        expect(page).to have_link(
          'Request Scan - Guest',
                            href: 'https://psu.illiad.oclc.org/illiad/upm/lending/lendinglogon.html'
        )
        expect(page).to have_link(
          'View in Special Collections',
                            href: 'https://aeon.libraries.psu.edu/Logon/?Action=10&Form=30&ReferenceNumber=123730&'\
                                  'Genre=BOOK&Location=Archival%20Thesis&ItemNumber=000052322808&CallNumber=Thesis%'\
                                  '201968mMyers%2CJE&ItemTitle=Ecology%20of%20the%20wild-trapped%20and%20transplant'\
                                  'ed%20ring-necked%20pheasant%20near%20Centre%20Hall%2C%20Pennsylvania&ItemAuthor=My'\
                                  'ers%2C%20James%20E.&ItemEdition=&ItemPublisher=publisher%20not%20identified&ItemPla'\
                                  'ce=Place%20of%20publication%20not%20identified&ItemDate=1968&ItemInfo1=&SubLocation='
        )
      end
    end
  end

  describe 'Hold Button - I want It', js: true do
    it 'displays when a record has least one holdable item' do
      visit '/catalog/1793712'
      within 'div[class*="hold-button"]' do
        expect(page).to have_link(
          'I Want It', href: 'http://cat.libraries.psu.edu/cgi-bin/catredirpg?C=1793712'
        )
      end
    end
    it 'does not display when a record has no holdable items' do
      visit '/catalog/107'
      expect(page).not_to have_link('I Want It')
    end
  end

  describe 'Bound Withs:', js: true do
    it 'only child holding\'s call number has text \'bound in\' with parent title' do
      visit '/catalog/53953'
      within 'div[data-library="UP-ANNEX"]' do
        expect(page).to have_selector 'td',
                                      exact_text: 'Microfilm E290 reel.1065 bound in The Hermit, or, A view of '\
                                            'the world, by a person retir\'d from it 1711'
        expect(page).to have_selector 'td', exact_text: 'AP3.M33 no.1-45, n.s.no.1-45 1710-12'
      end
    end

    it 'child holding has material type and location from parent' do
      visit '/catalog/53953'
      bound_holding = '//div[@data-library="UP-ANNEX"]//tr[td//text()[contains(., \'Microfilm E290 reel.1065\')]]'
      within :xpath, bound_holding do
        expect(page).to have_content('Microfilm, Microfiche, etc.')
        expect(page).to have_content('Submit request for annexed material')
      end
    end

    it 'a record with 3 parents, have 3 holdings with bound in text' do
      visit '/catalog/2679972'
      within 'div[data-library="UP-SPECCOL"]' do
        expect(page).to have_xpath './/tr[td//text()[contains(., \'bound in\')]]', count: 3
      end
    end
  end

  describe 'Request via ILL link' do
    it 'displays if a record has a holding in an ILL location', js: true do
      visit '/catalog/5112336'
      within 'div[data-library="HARRISBURG"]' do
        expect(page).to have_link(
          'Copy unavailable, request via Interlibrary Loan',
                             href: 'https://psu-illiad-oclc-org.ezaccess.libraries.psu.edu/illiad/upm/illiad.dll/'\
                                   'OpenURL?Action=10&Form=30&isbn=9781599901091 (hardcover),1599901099 (hardcover)'\
                                   '&title=Sun%20and%20moon%2C%20ice%20and%20snow&callno=PZ8.G3295Su%202008&rfr_id='\
                                   'info%3Asid%2Fcatalog.libraries.psu.edu&aulast=George%2C%20Jessica%20Day%2C%201976'\
                                   '-&date=2008'
        )
      end
    end

    it 'doesn\'t display if a record does not have a holding in a ILL location', js: true do
      visit '/catalog/1839879'
      expect(page).not_to have_link 'Copy unavailable, request via Interlibrary Loan'
    end
  end
end