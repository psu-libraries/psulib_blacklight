# frozen_string_literal: true

require 'rails_helper'
require 'support/vcr'

RSpec.describe 'Availability', :vcr, type: :feature do
  let(:hold_button_url) { "#{Settings.my_account_url}#{Settings.hold_button_path}" }

  before do
    stub_request(:get, /https:\/\/catalog.hathitrust.org\/api\/volumes\/brief\//)
    Settings.readonly = false
    Settings.hide_hold_button = false
    Settings.hide_etas_holdings = false
  end

  describe 'User searches for a record', js: true do
    it 'that has holdings and a \'View Availability\' button' do
      visit '/?utf8=✓&search_field=all_fields&q=9781599901091'
      expect(page).to have_css 'button[data-target="#availability-5112336"]'
    end

    it 'that has holdings but none are available' do
      visit '/?utf8=✓&search_field=all_fields&q=Eva+Oper+in+drei+Akten'
      # Shouldn't show the location teaser text next to the show availability button
      expect(page).to have_css '.availability-snippet', exact_text: ''
    end

    it 'that has holdings available in 3 or more locations' do
      visit '/?utf8=✓&search_field=all_fields&q=0802132138'
      expect(page).to have_css '.availability-snippet', exact_text: 'Multiple Locations'
    end

    it 'that has holdings available in exactly 2 locations' do
      visit '/?utf8=✓&search_field=all_fields&q=23783767'
      expect(page).to have_css '.availability-snippet',
                               exact_text: 'Penn State Hazleton, Penn State Mont Alto'
    end

    it 'that has holdings available in only 1 location' do
      visit '/?utf8=✓&search_field=all_fields&q=9788836636174'
      expect(page).to have_css '.availability-snippet',
                               exact_text: 'Pattee Library and Paterno Library Stacks'
    end

    it 'and clicks the \'View Availability\' button to display and hide holdings' do
      visit '/?utf8=✓&search_field=all_fields&q=9781599901091'
      expect(page).to have_css 'button[data-target="#availability-5112336"]'
      expect(page).not_to have_css '#availability-5112336'
      click_button('View Availability')
      expect(page).not_to have_css '.availability-5112336', wait: 3
      expect(page).to have_content 'PZ8.G3295Su 2008'
      expect(page).to have_content 'Fiction G4672sun 2008'
    end

    it 'that is an online resource and has no holdings to display' do
      visit '/?utf8=✓&search_field=all_fields&q=D-humanos+Arruti%2C+Mariana'
      expect(page).not_to have_css 'button[data-target="#availability-22091400"]'
      expect(page).not_to have_css '#availability-22091400'
    end

    it 'that is an online resource and all copies are on order' do
      visit '/?search_field=all_fields&q=33183518'
      expect(page).to have_css 'div[class="availability"][data-keys="33183518"]'
      expect(page).to have_css 'strong', text: /Being acquired by the library/
    end

    it 'that has a public note' do
      visit '/?utf8=✓&search_field=all_fields&q=6962697'
      click_button('View Availability')
      expect(page).to have_css 'i.fa-info-circle[data-toggle="tooltip"][data-original-title="Struwwelpeter"]'
    end

    it 'that does NOT have a public note' do
      visit '/?utf8=✓&search_field=all_fields&q=2422046'
      click_button('View Availability')
      expect(page).not_to have_css 'i.fa-info-circle[data-toggle="tooltip"]'
    end

    it 'that has summary holdings information' do
      visit '/?utf8=✓&search_field=all_fields&q=1793712'
      click_button('View Availability')
      expect(page).to have_css 'tr.table-primary .h6', text: 'Stacks - General Collection: Holdings Summary'
    end

    context 'when Hathi ETAS is enabled' do
      before do
        Settings.hathi_etas = true
      end

      it 'an etas record displays the \'View Availability\' button but hides the hold button' do
        visit '/?search_field=all_fields&q=Yidishe+bleter+in+Amerike'
        expect(page).to have_css 'button[data-target="#availability-3753687"]'
        expect(page).not_to have_css '#availability-3753687'
        click_button('View Availability')
        expect(page).not_to have_css '.availability-3753687', wait: 3
        expect(page).to have_content 'PN4885.Y5C5 1946'
        expect(page).not_to have_link(
          'I Want It', href: "#{hold_button_url}3753687"
        )
      end

      context 'when hide Hathi ETAS holdings is enabled' do
        before do
          Settings.hide_etas_holdings = true
        end

        it "an etas record does not display 'View Availability' button even though there are holdable items" do
          skip "This record doesn't seem to be ETAS anymore, so availability is showing when it shouldn't"
          visit '/?search_field=all_fields&q=Yidishe+bleter+in+Amerike'
          expect(page).not_to have_css 'button[data-target="#availability-3753687"]'
        end
      end
    end

    context 'when Hathi ETAS is disabled' do
      it 'an etas record displays \'View Availability\' button and hold button' do
        visit '/?search_field=all_fields&q=Yidishe+bleter+in+Amerike'
        expect(page).to have_css 'button[data-target="#availability-3753687"]'
        expect(page).not_to have_css '#availability-3753687'
        click_button('View Availability')
        expect(page).not_to have_css '.availability-3753687', wait: 3
        expect(page).to have_content 'PN4885.Y5C5 1946'
        expect(page).to have_link(
          'I Want It', href: "#{hold_button_url}3753687"
        )
      end
    end

    context 'when all items are on course reserves' do
      it 'hides the hold button' do
        visit '/?search_field=all_fields&q=Employment+law'
        expect(page).to have_css 'button[data-target="#availability-9186426"]'
        click_button('View Availability')
        expect(page).not_to have_link(
          'I Want It', href: "#{hold_button_url}9186426"
        )
      end
    end

    context 'when not all items are on course reserves' do
      it 'displays the hold button' do
        visit '/?search_field=all_fields&q=+40+short+stories+%3A+a+portable+anthology'
        expect(page).to have_css 'button[data-target="#availability-23783767"]'
        click_button('View Availability')
        expect(page).to have_link(
          'I Want It', href: "#{hold_button_url}23783767"
        )
      end
    end
  end

  describe 'User visits catalog record page', js: true do
    it 'that has holdings to display' do
      visit '/catalog/370199'
      expect(page).to have_css 'div[class="availability"][data-keys="370199"]'
      expect(page).to have_content 'NK9406.L48'
    end

    it 'that is an online resource and has no holdings to display' do
      visit '/catalog/22091400'
      expect(page).not_to have_css 'div[class="availability"]'
    end

    it 'that is an online resource and all copies are on order' do
      visit '/catalog/33183518'
      expect(page).to have_css 'div[class="availability"][data-keys="33183518"]'
      expect(page).to have_css 'h5', text: /Being acquired by the library/
    end

    it 'that has a public note' do
      visit '/catalog/6962697'
      expect(page).to have_css 'i.fa-info-circle[data-toggle="tooltip"][data-original-title="Struwwelpeter"]'
    end

    it 'that does NOT have a public note' do
      visit '/?utf8=✓&search_field=all_fields&q=2422046'
      expect(page).not_to have_css 'i.fa-info-circle[data-toggle="tooltip"]'
    end

    it 'that has an item on course reserve' do
      visit '/catalog/3500414'
      expect(page).to have_css 'div[class="availability"][data-keys="3500414"]'
      expect(page).to have_css 'strong', text: /Due back at:/
      expect(page).to have_content '9:01 AM on 3/4/2019'
      expect(page).to have_content 'Reserve - 24 hour loan w/ 1 renewal'
    end

    it 'that has summary holdings information' do
      visit '/catalog/1793712'
      expect(page).to have_css 'tr.table-primary .h6', text: 'Stacks - General Collection: Holdings Summary'
    end

    context 'when HathiTrust ETAS is enabled' do
      before do
        Settings.hathi_etas = true
      end

      it 'an ETAS record displays holdings' do
        visit '/catalog/3753687'
        expect(page).to have_css 'div[class="availability"][data-keys="3753687"]'
      end

      context 'when hide HathiTrust ETAS holdings is enabled' do
        before do
          Settings.hide_etas_holdings = true
        end

        it 'an etas record does not display holdings even though there are holdable items' do
          skip "This record doesn't seem to be ETAS anymore, so availability is showing when it shouldn't"
          visit '/catalog/3753687'
          expect(page).not_to have_css 'div[class="availability"][data-keys="3753687"]'
        end
      end
    end

    context 'when HathiTrust ETAS is disabled' do
      it 'an etas record displays holdings when there are holdable items' do
        visit '/catalog/3753687'
        expect(page).to have_css 'div[class="availability"][data-keys="3753687"]'
      end
    end

    describe 'User opens a record with many holdings in a library' do
      it 'toggles 4 or more holdings with View More/View Less button' do
        visit '/catalog/1793712'
        within 'div[data-library="UP-PAT"]' do
          expect(page).to have_css 'button', text: /View More/
          expect(page).not_to have_css 'button', text: /View Less/
          expect(page).to have_xpath './/tbody/tr', count: 6
          click_button('View More')
          expect(page).to have_xpath './/tbody/tr', count: 79
          expect(page).not_to have_css 'button', text: /View More/
        end
      end
    end

    describe 'Archival Material:' do
      it 'has a "Request Material" link so it can be requested through Aeon' do
        visit '/catalog/1836205'
        click_button('View More')
        sleep 1 # It seems to be taking a little longer to expand this list than it used to
        expect(page).to have_link(
          'Request Material',
          href: 'https://aeon.libraries.psu.edu/Logon/?Action=10&Form=30&ReferenceNumber=' \
                '1836205&Genre=ARCHIVES&Location=Stored%20offsite.%20Ask%20at%20Special%20' \
                'Collections%2C%20104%20Paterno&ItemNumber=000076996122&CallNumber=' \
                'RBM%202457%20box19%20AX%2FSP%2F10156%2F09&ItemTitle=Fiona%20Pitt-Kethley%20' \
                'literary%20papers&ItemAuthor=Pitt-Kethley%2C%20Fiona%2C%201954-&ItemEdition' \
                '=&ItemPublisher=&ItemPlace=&ItemDate=&ItemInfo1=Unrestricted%20access.&SubLocation='
        )
      end

      it 'has a \'Request Material\' link with subLocation info' do
        visit '/catalog/107'
        # The important part below is `&SubLocation=Christmas%3B%20Nathaniel%20Hawthorne` which fills out a hidden input
        # in the AEON request form.
        expect(page).to have_link(
          'Request Material',
          href: 'https://aeon.libraries.psu.edu/Logon/?Action=10&Form=30&ReferenceNumber=107&' \
                'Genre=BOOK&Location=Rare%20Books%20%26%20Manuscripts%2C%201st%20Floor%20Paterno%2C%2' \
                '0American%20Literature%20Collection&ItemNumber=000021534850&CallNumber=AP2.O354%201870%' \
                '2F71&ItemTitle=The%20Christmas%20locket&ItemAuthor=&ItemEdition=&ItemPublish' \
                'er=Roberts%20brothers&ItemPlace=Boston&ItemDate=1870-&ItemInfo1=&SubLocation' \
                '=Christmas%3B%20Nathaniel%20Hawthorne'
        )
      end
    end

    describe 'Archival Thesis:' do
      it 'has links for requesting scans' do
        visit '/catalog/123730'
        within 'div[data-library="UP-ANNEX"]' do
          expect(page).to have_link(
            'Request Scan - Penn State Users',
            href: 'https://psu.illiad.oclc.org/illiad/upm/illiad.dll/' \
                  'OpenURL?Action=10&Form=20&Genre=GenericRequestThesisDigitization&title=Ecology' \
                  '%20of%20the%20wild-trapped%20and%20transplanted%20ring-necked%20pheasant%20near' \
                  '%20Centre%20Hall%2C%20Pennsylvania&callno=Thesis%201968mMyers%2CJE&rfr_id=info' \
                  '%3Asid%2Fcatalog.libraries.psu.edu&aulast=Myers%2C%20James%20E.&date=1968'
          )
          expect(page).to have_link(
            'Request Scan - Guest',
            href: 'https://psu.illiad.oclc.org/upm2/lending/lendinglogon.html'
          )
          expect(page).to have_link(
            'View in Special Collections',
            href: 'https://aeon.libraries.psu.edu/Logon/?Action=10&Form=30&ReferenceNumber=123730&' \
                  'Genre=BOOK&Location=Archival%20Thesis&ItemNumber=000052322808&CallNumber=Thesis%' \
                  '201968mMyers%2CJE&ItemTitle=Ecology%20of%20the%20wild-trapped%20and%20transplant' \
                  'ed%20ring-necked%20pheasant%20near%20Centre%20Hall%2C%20Pennsylvania&ItemAuthor=My' \
                  'ers%2C%20James%20E.&ItemEdition=&ItemPublisher=publisher%20not%20identified&ItemPla' \
                  'ce=Place%20of%20publication%20not%20identified&ItemDate=1968&ItemInfo1=&SubLocation='
          )
        end
      end
    end

    describe 'Hold Button - I want It' do
      context 'when I Want It is in readonly state' do
        before do
          Settings.hide_hold_button = true
        end

        it 'does not display even for a record with holdable items' do
          visit '/catalog/21588551'
          expect(page).not_to have_link(
            'I Want It', href: "#{hold_button_url}21588551"
          )
        end
      end

      context 'when I Want It is not in readonly state' do
        it 'displays when a record has at least one holdable item' do
          visit '/catalog/18879591'
          within 'div[class*="hold-button"]' do
            expect(page).to have_link(
              'I Want It', href: "#{hold_button_url}18879591"
            )
          end
        end

        it 'does not display when a record has no holdable items' do
          visit '/catalog/107'
          expect(page).not_to have_link(
            'I Want It', href: "#{hold_button_url}107"
          )
        end
      end

      context 'when Hathi ETAS is enabled' do
        before do
          Settings.hathi_etas = true
        end

        it 'does not display for an etas record even with holdable items' do
          visit '/catalog/3753687'
          expect(page).not_to have_link(
            'I Want It', href: "#{hold_button_url}3753687"
          )
        end
      end

      context 'when Hathi ETAS is disabled' do
        it 'displays for an etas record if there are holdable items' do
          visit '/catalog/3753687'
          expect(page).to have_link(
            'I Want It', href: "#{hold_button_url}3753687"
          )
        end
      end

      context 'when all items are on course reserves' do
        it 'hides the hold button' do
          visit '/catalog/9186426'
          expect(page).not_to have_link(
            'I Want It', href: "#{hold_button_url}9186426"
          )
        end
      end

      context 'when not all items are on course reserves' do
        it 'displays the hold button' do
          visit '/catalog/23783767'
          expect(page).to have_link(
            'I Want It', href: "#{hold_button_url}23783767"
          )
        end
      end
    end

    describe 'Bound Withs:' do
      it 'only child holding\'s call number has text \'bound in\' with parent title' do
        visit '/catalog/53953'
        within 'div[data-library="UP-ANNEX"]' do
          expect(page).to have_css 'td',
                                   exact_text: 'Microfilm E290 reel.1065 bound in The Hermit, or, A view of ' \
                                               'the world, by a person retir\'d from it 1711'
          expect(page).to have_css 'td', exact_text: 'AP3.M33 no.1-45, n.s.no.1-45 1710-12'
        end
      end

      it 'child holding has material type and location from parent' do
        visit '/catalog/53953'
        bound_holding = '//div[@data-library="UP-ANNEX"]//tr[td//text()[contains(., \'Microfilm E290 reel.1065\')]]'
        within :xpath, bound_holding do
          expect(page).to have_content 'Microfilm, Microfiche, etc.'
          expect(page).to have_content 'Annexed Material'
        end
      end

      it 'a record with 3 parents, have 3 holdings with bound in text' do
        visit '/catalog/2679972'
        within 'div[data-library="UP-SPECCOL"]' do
          expect(page).to have_xpath './/tr[td//text()[contains(., \'bound in\')]]', count: 3
        end
      end

      context 'when all items are on course reserves' do
        it 'hides the hold button' do
          visit '/catalog/29252445'
          expect(page).not_to have_link(
            'I Want It', href: "#{hold_button_url}29252445"
          )
        end
      end
    end

    describe 'Request a map scan' do
      it 'appends a link to request a scan that opens in a new window' do
        visit '/catalog/25095210'
        scan_link = find_link 'Request scan'

        expect(scan_link[:target]).to eq '_blank'
      end

      it 'appends a link to request a scan even when there is an AEON or ILL link already present' do
        visit '/catalog/24519'

        within('div[data-library="UP-MAPS"]') do
          expect(page).to have_link 'Request scan'
        end
      end

      it 'appends links to request map scans for a record with many holdings' do
        visit '/catalog/25095210'
        within 'div[data-library="UP-MAPS"]' do
          expect(page).to have_xpath './/tbody/tr[td//text()[contains(., \'Request scan\')]]', count: 4
          click_button('View More')
          expect(page).to have_xpath './/tbody/tr[td//text()[contains(., \'Request scan\')]]', count: 50
          expect(page).not_to have_css 'button', text: /View More/
        end
      end
    end

    describe 'News & Microforms Scan Request' do
      it 'display the correct ILL url'
    end
  end
end
